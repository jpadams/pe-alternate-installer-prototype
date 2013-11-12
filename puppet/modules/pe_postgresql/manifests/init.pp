class pe_postgresql (
  $version = '9.2',
) {

  class { 'postgresql::globals':
    confdir          => "/opt/puppet/var/lib/pgsql/${version}/data",
    bindir           => '/opt/puppet/bin',
    default_database => 'pe-postgres',
  }

}
