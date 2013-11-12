# Configures the PostgreSQL database backend for the Puppet Enterprise Console
#
class pe_console::database (
  $console_password,
  $consoleauth_password,
  $inventoryservice_password,
  $console_database          = 'console',
  $console_username          = 'console',
  $consoleauth_database      = 'console_auth',
  $consoleauth_username      = 'console_auth',
  $inventoryservice_database = 'console_inventory_service',
  $inventoryservice_username = 'console',
) {
  include pe_postgresql

  postgresql::server::tablespace { 'pe_console':
    location => '/opt/puppet/var/lib/pgsql/9.2/console',
    spcname  => 'pe-console',
  } ->

  postgresql::server::role { $consoleauth_username:
    password_hash => postgresql_password($consoleauth_username, $consoleauth_password),
  } ->
  postgresql::server::role { $console_username:
    password_hash => postgresql_password($console_username, $console_password),
  } ->

  postgresql::server::database { $consoleauth_database:
    owner      => $consoleauth_username,
    tablespace => 'pe-console',
    encoding   => 'utf8',
    locale     => 'en_US.utf8',
  } ->
  postgresql::server::database { $console_database:
    owner      => $console_username,
    tablespace => 'pe-console',
    encoding   => 'utf8',
    locale     => 'en_US.utf8',
  }

}
