#
# This is a top-level wrapper class intended to be used in an environment
# where most parameters come from hiera. Every default should be undef if
# it's really just a passthrough to a lower-level class (defaults will be
# supplied by that lower-level class).
#
class pe_console (
  $dashboard_certname         = undef,
  $dashboard_db_host          = undef,
  $dashboard_db_port          = undef,
  $dashboard_db_database      = undef,
  $dashboard_db_username      = undef,
  $dashboard_db_password      = undef,
  $dashboard_root             = undef,
  $consoleauth_db_host        = undef,
  $consoleauth_db_port        = undef,
  $consoleauth_db_database    = undef,
  $consoleauth_db_username    = undef,
  $consoleauth_db_password    = undef,
  $consoleauth_login_username = undef,
  $consoleauth_login_password = undef,
  $inventory_host             = undef,
  $inventory_port             = undef,
  $filebucket_host            = undef,
  $filebucket_port            = undef,
  $ca_host                    = undef,
  $ca_port                    = undef,
  $smtp_host                  = undef,
  $smtp_username              = undef,
  $smtp_password              = undef,
  $consoleauth_console_host   = undef,
  $casclient_casport          = undef,
  $casclient_cashost          = undef,
  $casclient_sessionsecret    = undef,
  $casclient_sessionkey       = undef,
  $casserver_db_host          = undef,
  $casserver_db_password      = undef,
  $casserver_db_port          = undef,
  $casserver_db_database      = undef,
  $casserver_db_username      = undef,
  $casserver_db_adapter       = undef,
  $pe_console_version         = installed,
  $pe_livemanagement_version  = installed,
  $pe_eventinspector_version  = installed,
  $pe_license_version         = installed,
  $pe_licensestatus_version   = installed,
  $puppetdb_host              = undef,
  $puppetdb_port              = undef,
) {
  include pe_httpd
  include pe_postgresql::client

  anchor { 'pe_console::pre':
    before  => Anchor['pe_console::begin'],
    require => Class['pe_postgresql::client'],
  }

  # Necessary for when pe_role::puppetconsole is used in conjunction with
  # pe_role::puppetconsoledb.
  anchor { 'pe_console::begin': }

  class { 'pe_console::dashboard':
    certname        => $dashboard_certname,
    db_host         => $dashboard_db_host,
    db_port         => $dashboard_db_port,
    db_database     => $dashboard_db_database,
    db_username     => $dashboard_db_username,
    db_password     => $dashboard_db_password,
    inventory_host  => $inventory_host,
    inventory_port  => $inventory_port,
    filebucket_host => $filebucket_host,
    filebucket_port => $filebucket_port,
    ca_host         => $ca_host,
    ca_port         => $ca_port,
    dashboard_root  => $dashboard_root,
    before          => Anchor['pe_console::end'],
    require         => Anchor['pe_console::begin'],
  }

  class { 'pe_console::console_auth':
    require              => Anchor['pe_console::begin'],
    before               => Anchor['pe_console::end'],
    db_host              => $consoleauth_db_host,
    db_port              => $consoleauth_db_port,
    db_database          => $consoleauth_db_database,
    db_username          => $consoleauth_db_username,
    db_password          => $consoleauth_db_password,
    smtp_host            => $smtp_host,
    smtp_username        => $smtp_username,
    smtp_password        => $smtp_password,
    console_absolute_url => $consoleauth_console_host,
    login_username       => $consoleauth_login_username,
    login_password       => $consoleauth_login_password,
  }

  class { 'pe_console::cas_client':
    require        => Anchor['pe_console::begin'],
    before         => Anchor['pe_console::end'],
  }

  class { 'pe_console::cas_server':
    require        => Anchor['pe_console::begin'],
    before         => Anchor['pe_console::end'],
    db_host        => $casserver_db_host,
    db_password    => $casserver_db_password,
    db_port        => $casserver_db_port,
    db_database    => $casserver_db_database,
    db_username    => $casserver_db_username,
    db_adapter     => $casserver_db_adapter,
  }

  class { 'pe_console::license_status':
    require        => Anchor['pe_console::begin'],
    before         => Anchor['pe_console::end'],
    ssl_keyfile    => "${dashboard_root}/certs/${dashboard_certname}.private_key.pem",
    ssl_certfile   => "${dashboard_root}/certs/${dashboard_certname}.cert.pem",
    ssl_cacertfile => "${dashboard_root}/certs/${dashboard_certname}.ca_cert.pem",
    puppetdb_host  => $puppetdb_host,
    puppetdb_port  => $puppetdb_port,
  }

  class { 'pe_console::certificate_manager':
    require => Anchor['pe_console::begin'],
    before  => Anchor['pe_console::end'],
  }

  class { 'pe_console::event_inspector':
    require        => Anchor['pe_console::begin'],
    before         => Anchor['pe_console::end'],
    version        => $pe_eventinspector_version,
    ssl_keyfile    => "${dashboard_root}/certs/${dashboard_certname}.private_key.pem",
    ssl_certfile   => "${dashboard_root}/certs/${dashboard_certname}.cert.pem",
    ssl_cacertfile => "${dashboard_root}/certs/${dashboard_certname}.ca_cert.pem",
    puppetdb_host  => $puppetdb_host,
    puppetdb_port  => $puppetdb_port,
  }

  package { 'pe-console':
    ensure => $pe_console_version,
  }
  package { 'pe-live-management':
    ensure => $pe_livemanagement_version,
  }
  package { 'pe-license':
    ensure => $pe_license_version,
  }

  anchor { 'pe_console::end': }

}
