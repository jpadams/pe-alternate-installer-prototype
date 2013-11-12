class pe_postgresql::client {
  include pe_postgresql

  class { 'postgresql::client':
    package_name => 'pe-postgresql',
    require      => Anchor['pe_postgresql::client::begin'],
    before       => Anchor['pe_postgresql::client::end'],
  }

  anchor { 'pe_postgresql::client::begin': }
  anchor { 'pe_postgresql::client::end':   }

}
