# == Class: pe_role::puppetconsole
#
# The pe_role::puppetconsole class is a top-level role classifier that
# leverages default values set in pe_role and functionality provided by the
# pe_console module.
#
# === Parameters
#
# [*dashboard_certname*]
#   The certificate name to use for the puppet-dashboard service. This
#   certificate will be created if it does not exist on the system, and is used
#   to communicate with the Puppet Master service(s).
#
# [*dashboard_db_host*]
#   The resolvable name used to reach the database backend for the 
#   puppet-dashboard service.
#
# [*dashboard_db_port*]
#   The port used to connect to the puppet-dashboard service's database
#   backend.
#
# [*dashboard_db_database*]
#   The database name used by the puppet-dashboard service.
#
# [*dashboard_db_username*]
#   The username for logging in to the database backend for the
#   puppet-dashboard service.
#
# [*dashboard_db_password*]
#   The password for logging in to the database backend for the
#   puppet-dashboard service.
#
# [*dashboard_root*]
#   The directory in which the puppet-dashboard application is installed.
#
# [*consoleauth_db_host*]
#   The resolvable name used to reach the database backend for the 
#   console-auth service.
#
# [*consoleauth_db_port*]
#   The port used to connect to the console-auth service's database
#   backend.
#
# [*consoleauth_db_database*]
#   The database name used by the console-auth service.
#
# [*consoleauth_db_username*]
#   The username for logging in to the database backend for the
#   console-auth service.
#
# [*consoleauth_db_password*]
#   The password for logging in to the database backend for the
#   console-auth service.
#
# [*consoleauth_login_username*]
#   A username to pre-configure with administrator rights to services that
#   use console-auth. If specified, this login username will be added to the
#   console-auth database as an administrator. It should be in the form of an
#   email address.
#
# [*consoleauth_login_password*]
#   The password for the user specified in consoleauth_login_username.
#
# [*inventory_host*]
#   The resolvable name to use to reach the Puppet inventory service.
#
# [*inventory_port*]
#   The port over which the inventory service is available.
#
# [*filebucket_host*]
#   The resolvable name to use to reach the Puppet filebucket service.
#
# [*filebucket_port*]
#   The port over which the filebucket service is available.
#
# [*ca_host*]
#   The resolvable certificate authority hostname or fully qualified domain
#   name.
#
# [*ca_port*]
#    The port over which the CA service is available.
#
# [*smtp_host*]
#   The resolvable name of the SMTP mail server.
#
# [*smtp_username*]
#   If necessary, the username to use when authenticating to the SMTP server.
#
# [*smtp_password*]
#   If necessary, the password to use when authenticating to the SMTP server.
#
# [*consoleauth_console_host*]
#   When configuring the console-auth service, the resolvable name to specify
#   has the console.
#
# [*casclient_casport*]
#   For the CAS client, the port over which to connect to the CAS server.
#
# [*casclient_cashost*]
#   For the CAS client, the resolvable name to use to connect to the CAS
#   server.
#
# [*casclient_sessionsecret*]
#   For the CAS client, the session secret key.
#
# [*casclient_sessionkey*]
#   For the CAS client, the session key.
#
# [*casserver_db_host*]
#   For the CAS server, the resolvable name to use to connect to the CAS
#   server's database backend.
#
# [*casserver_db_password*]
#   For the CAS server, the password to use to authenticate to the database
#   backend.
#
# [*casserver_db_port*]
#   For the CAS server, the port over which to connect to the CAS server's
#   database backend.
#
# [*casserver_db_database*]
#   For the CAS server, the name of the database to use.
#
# [*casserver_db_username*]
#   For the CAS server, the username to use to authenticate to the database
#   backend.
#
class pe_role::puppetconsole (
  $dashboard_certname         = "${pe_role::puppetconsole_cert_prefix}.${::clientcert}",
  $dashboard_db_host          = $pe_role::puppetconsole_db,
  $dashboard_db_port          = '5432',
  $dashboard_db_database      = 'console',
  $dashboard_db_username      = 'console',
  $dashboard_db_password      = $pe_role::console_password,
  $dashboard_root             = '/opt/puppet/share/puppet-dashboard',
  $consoleauth_db_host        = $pe_role::puppetconsole_db,
  $consoleauth_db_port        = '5432',
  $consoleauth_db_database    = 'console_auth',
  $consoleauth_db_username    = 'console_auth',
  $consoleauth_db_password    = $pe_role::consoleauth_password,
  $consoleauth_login_username = $pe_role::console_login_username,
  $consoleauth_login_password = $pe_role::console_login_password,
  $inventory_host             = $pe_role::puppetinventory,
  $inventory_port             = '8140',
  $filebucket_host            = $pe_role::puppetfilebucket,
  $filebucket_port            = '8140',
  $ca_host                    = $pe_role::puppetca,
  $ca_port                    = '8140',
  $smtp_host                  = 'localhost',
  $smtp_username              = undef,
  $smtp_password              = undef,
  $consoleauth_console_host   = 'localhost',
  $casclient_casport          = undef,
  $casclient_cashost          = undef,
  $casclient_sessionsecret    = undef,
  $casclient_sessionkey       = 'puppet_enterprise_console',
  $casserver_db_host          = $pe_role::puppetconsole_db,
  $casserver_db_password      = $pe_role::consoleauth_password,
  $casserver_db_port          = '5432',
  $casserver_db_database      = 'console_auth',
  $casserver_db_username      = 'console_auth',
  $puppetdb_host              = $pe_role::puppetdb,
  $puppetdb_port              = '8081',
) inherits pe_role {

  # TODO: This is a hack. The pe_mcollective module has not yet been
  #       re-engineered to support any kind of elastic deployment.
  include pe_mcollective::role::console

  class { 'pe_console':
    require                    => Anchor['pe_role::setup_database'],
    dashboard_certname         => $dashboard_certname,
    dashboard_db_host          => $dashboard_db_host,
    dashboard_db_port          => $dashboard_db_port,
    dashboard_db_database      => $dashboard_db_database,
    dashboard_db_username      => $dashboard_db_username,
    dashboard_db_password      => $dashboard_db_password,
    dashboard_root             => $dashboard_root,
    consoleauth_db_host        => $consoleauth_db_host,
    consoleauth_db_port        => $consoleauth_db_port,
    consoleauth_db_database    => $consoleauth_db_database,
    consoleauth_db_username    => $consoleauth_db_username,
    consoleauth_db_password    => $consoleauth_db_password,
    consoleauth_login_username => $consoleauth_login_username,
    consoleauth_login_password => $consoleauth_login_password,
    inventory_host             => $inventory_host,
    inventory_port             => $inventory_port,
    filebucket_host            => $filebucket_host,
    filebucket_port            => $filebucket_port,
    ca_host                    => $ca_host,
    ca_port                    => $ca_port,
    smtp_host                  => $smtp_host,
    smtp_username              => $smtp_username,
    smtp_password              => $smtp_password,
    consoleauth_console_host   => $consoleauth_console_host,
    casclient_casport          => $casclient_casport,
    casclient_cashost          => $casclient_cashost,
    casclient_sessionsecret    => $casclient_sessionsecret,
    casclient_sessionkey       => $casclient_sessionkey,
    casserver_db_host          => $casserver_db_host,
    casserver_db_password      => $casserver_db_password,
    casserver_db_port          => $casserver_db_port,
    casserver_db_database      => $casserver_db_database,
    casserver_db_username      => $casserver_db_username,
    puppetdb_host              => $puppetdb_host,
    puppetdb_port              => $puppetdb_port,
  }

  # Export a whitelist entry for PuppetDB
  @@pe_role::util::puppetdb_whitelist { "export from ${dashboard_certname}":
    ensure  => present,
    line    => $dashboard_certname,
  }

}
