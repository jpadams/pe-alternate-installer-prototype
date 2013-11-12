# Class: pe_postgresql
#
# This module manages pe_postgresql
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class pe_postgresql::server (
  $listen_addresses        = undef,
  $ip_mask_allow_all_users = undef,
) inherits pe_postgresql {

  class { 'postgresql::server':
    package_name             => 'pe-postgresql-server',
    datadir                  => "/opt/puppet/var/lib/pgsql/${version}/data",
    service_name             => 'pe-postgresql',
    user                     => 'pe-postgres',
    group                    => 'pe-postgres',
    locale                   => 'en_US.UTF8',
    encoding                 => 'UTF8',
    needs_initdb             => true,
    version                  => $version,
    service_status           => 'service pe-postgresql status',
    listen_addresses         => $listen_addresses,
    ip_mask_allow_all_users  => $ip_mask_allow_all_users,
  }

  include pe_postgresql::client
  include pe_postgresql::devel

}
