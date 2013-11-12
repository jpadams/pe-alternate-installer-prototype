class pe_role::database::puppetdb (
  $database = 'pe-puppetdb',
  $username = $pe_role::puppetdb_username,
  $password = $pe_role::puppetdb_password,
) inherits pe_role {
  include pe_role::database

  class { 'pe_puppetdb::database':
    before            => Anchor['pe_role::setup_database'],
    database_name     => $database,
    database_username => $username,
    database_password => $password,
  }

}
