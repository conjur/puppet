# Conjur

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with Conjur](#setup)
    * [What conjur affects](#what-conjur-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with conjur](#beginning-with-conjur)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

This module helps to integrate [Conjur](http://www.conjur.net) security solution
with Puppet-driven configuration, thus allowing you to:
- use externally-stored, access-controlled, audited secrets with minimal
  trust; the secrets never end up on the master and are fetched directly by
  the client,
- centrally and flexibly control and audit SSH access to hosts.

Tested on CentOS 6.5 with Puppet 3.7.1. Will probably work on any EL.

## Module Description

[Conjur](http://www.conjur.net) allows you to store secrets in an encrypted
database and control access to them; a host then can use its own security
credentials and identity to securely fetch the secrets and use them in
configuration.

Another feature of Conjur is central management of SSH access to hosts;
conjurized hosts are a first-class resource in Conjur RBAC engine and can
be access controlled with arbitrary flexibility and granularity.

This module handles
- installing Conjur client,
- configuring it,
- creating a host identity with Conjur host factory,
- configuring the host for Conjur SSH access control,
- fetching secrets and using them in config files.

## Setup

### What conjur affects

* conjur client package,
* conjur config and identity files - `/etc/conjur.{conf,identity}`.

If secrets management is used, then additionally
* any config files you conjurize.

If SSH access management is used, then additionally
* NSS, nslcd and sshd configuration.

### Setup Requirements

You should have a Conjur server configured with either a precreated identity
for the host or, alternatively, a host factory set up. You'll need the Conjur TLS
certificate, account info and endpoint URL, and either a host API key or a host
factory token.

### Beginning with conjur

To install the Conjur client and host identity:

    class { conjur:
      conjur_url => 'https://master.conjur.um.pl.eu.org/api'
      conjur_certificate => file("conjur/example.pem"),
      conjur_account => hatest,

      host_id => hftest,

      host_key => '3bfqryknzbbmh1j3ecftgyac9w22677hw27z9yns3rcf29h3w2hvgn',
      # alternatively, use a host factory token:
      hostfactory_token => '3bfqryknzbbmh1j3ecftgyac9w22677hw27z9yns3rcf29h3w2hvgn'
    }

## Usage

### Secrets from Conjur variables

Wherever there is a secret (password, API key, etc.) being stored in a config file,
you can instead use `conjur_variable` function to tie it in and then use `conjurize_file`
resource to process it. This allows using secrets from Conjur with non-Conjur-aware resources,
for example:

    $planet = conjur_variable('planet')

    file { '/etc/hello.txt':
      content => "Hello $planet!\n"
    }

    conjurize_file { '/etc/hello.txt':
      variable_map => {
        planet => "!var puppetdemo/planet"
      }
    }

### SSH access control

To configure the host for Conjur SSH access control, set `ssh` on `conjur`
class:

    class { conjur:
      conjur_url => 'https://master.conjur.um.pl.eu.org/api'
      conjur_certificate => file("conjur/example.pem"),
      conjur_account => hatest,

      host_id => hftest,

      host_key => '3bfqryknzbbmh1j3ecftgyac9w22677hw27z9yns3rcf29h3w2hvgn',

      ssh => true
    }

or declare `conjur::ssh` class directly:

    class { 'conjur::ssh': }

## Reference

### Classes

- `conjur::client`: Installs the Conjur client
- `conjur::host_identity`: Configures the Conjur client and sets up host identity
- `conjur::ssh`: Configures the host for Conjur SSH access control

### Functions

#### conjur_variable

A placeholder to use in config files to be substituted by a secret fetched from Conjur.

### Providers

#### conjur_gem

A package provider to install gems in Conjur embedded Ruby environment.

#### conjurize_file

Alters an existing `File` resource by substituting `conjur_variable`s according to
a given variable map.

##### `variable_map`

Sets up a mapping from named variables in the config file to variables stored on the
conjur server, ie.

    variable_map => {
      mysql_password => '!var puppet-1.0/mysql/password
    }

This will replace `conjur_variable('mysql_password')` in the conjurized file with the
contents of `puppet-1.0/mysql/password` Conjur variable.

Note the !var prefix; this is directly translated to yaml mapping file, please consult Conjur
documentation for further details on that.

## Limitations

In this development release only CentOS is currently supported.

## Development

Feel free to submit pull requests.
