# == Class: pe_role::database::console
#
# The pe_role::database::console class is a top-level role classifier that
# leverages default values set in pe_role and functionality provided by the
# pe_console module to configure a database backend for use by the PE Console
# application.
#
# === Parameters
#
# [*console_database*]
#   The name of the database to set up for use by the puppet-dashboard
#   application.
#
# [*console_username*]
#   The username to use to login to the database set up for use by the
#   puppet-dashboard service.
#
# [*console_password*]
#   The password to use to login to the database set up for use by the
#   puppet-dashboard service.
#
# [*consoleauth_database*]
#   The name of the database set up for use by the console-auth service.
#
# [*consoleauth_username*]
#   The username to use to login to the database set up for use by the
#   console-auth service.
#
# [*consoleauth_password*]
#   The password to use to login to the database set up for use by the
#   console-auth service.
#
# [*inventoryservice_database*]
#   The name of the database set up for use by the ActiveRecord puppet
#   inventory service.
#
# [*inventoryservice_username*]
#   The password to use to login to the database set up for use by the
#   ActiveRecord puppet inventory service.
#
# [*inventoryservice_password*]
#   The password to use to login to the database set up for use by the
#   ActiveRecord puppet inventory service.
#
class pe_role::database::console (
  $console_database          = 'console',
  $console_username          = 'console',
  $console_password          = $pe_role::console_password,
  $consoleauth_database      = 'console_auth',
  $consoleauth_username      = 'console_auth',
  $consoleauth_password      = $pe_role::consoleauth_password,
  $inventoryservice_database = 'console_inventory_service',
  $inventoryservice_username = 'console',
  $inventoryservice_password = $pe_role::console_password,
) inherits pe_role {
  include pe_role::database

  class { 'pe_console::database':
    before                    => Anchor['pe_role::setup_database'],
    console_password          => $console_password,
    consoleauth_password      => $consoleauth_password,
    inventoryservice_password => $inventoryservice_password,
    console_database          => $console_database,
    console_username          => $console_username,
    consoleauth_database      => $consoleauth_database,
    consoleauth_username      => $consoleauth_username,
    inventoryservice_database => $inventoryservice_database,
    inventoryservice_username => $inventoryservice_username,
  }

}
