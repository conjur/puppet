# Scenario 2: Fetch a secret given a host name and Host Factory token

class { conjur:
  appliance_url => $facts['appliance_url'],
  authn_login => $facts['authn_login'],
  host_factory_token => Sensitive($facts['host_factory_token']),
  ssl_certificate => $facts['ssl_certificate']
}

$secret = conjur::secret('inventory/db-password')

notify {"Writing this secret to file: ${secret.unwrap}":}

file { '/tmp/test.pem':
  content => conjur::secret('inventory/db-password'),
  ensure => file,
}
