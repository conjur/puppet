#!/bin/bash

# This is an example of how to set environment variables before running
# the scripts in this directory. Modify this as needed for testing
# different versions of Puppet Agent or Windows. Source this as follows:
#
#       source set_env.sh

export COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-puppetmaster_$(openssl rand -hex 3)}"
export PUPPET_AGENT_VERSION="6.9.0"
export VAGRANT_CWD="windows2012"
# export VAGRANT_CWD="windows2016"
export SERVER_SIDE_CONFIG="false"
