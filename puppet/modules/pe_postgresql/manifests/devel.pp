class pe_postgresql::devel {
  include pe_postgresql

  class { 'postgresql::lib::devel':
    package_name => 'pe-postgresql-devel',
    require      => Anchor['pe_postgresql::devel::begin'],
    before       => Anchor['pe_postgresql::devel::end'],
  }

  anchor { 'pe_postgresql::devel::begin': }
  anchor { 'pe_postgresql::devel::end':   }

}
