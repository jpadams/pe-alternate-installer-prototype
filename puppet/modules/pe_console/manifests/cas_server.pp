class pe_console::cas_server (
  $db_host,
  $db_password,
  $db_port        = undef,
  $db_database    = 'console_auth',
  $db_username    = 'console_auth',
  $db_adapter     = 'postgresql',
  $authenticators = undef,
  $config         = '/etc/puppetlabs/rubycas-server/config.yml',
) {
  include pe_httpd

  Yaml_setting {
    target  => $config,
    notify  => Service['pe-httpd'],
    require => Package['pe-rubycas-server'],
  }

  package { 'pe-rubycas-server':
    ensure => installed,
  }

  file { $config:
    ensure  => file,
    owner   => 'pe-auth',
    group   => 'pe-auth',
    mode    => '0600',
    require => Package['pe-rubycas-server'],
  }
  file { '/var/log/pe-console-auth/cas.log':
    ensure => file,
    owner  => 'pe-auth',
    group  => 'puppet-dashboard',
    mode   => '0660',
  }

  # Optional values for database
  if $db_host {
    yaml_setting { 'pe_console-cas_server-db_host':
      key   => 'database/host',
      value => $db_host,
    }
  }
  if $db_password {
    yaml_setting { 'pe_console-cas_server-db_password':
      nodisplay => true,
      key       => 'database/password',
      value     => $db_password,
    }
  }
  if $db_port {
    yaml_setting { 'pe_console-cas_server-db_port':
      key   => 'database/port',
      type  => 'integer',
      value => $db_port,
    }
  }

  # Default-enabled values for database
  yaml_setting { 'pe_console-cas_server-database':
    key   => 'database/database',
    value => $db_database,
  }
  yaml_setting { 'pe_console-cas_server-db_adapter':
    key   => 'database/adapter',
    value => $db_adapter,
  }
  yaml_setting { 'pe_console-cas_server-db_username':
    key   => 'database/username',
    value => $db_username,
  }

  # Determine whether or not to build the default authenticator, based on
  # the parameters passed in
  if ($db_database and $db_username and $db_password) {
    $use_db_host = $db_host ? { undef => 'localhost', default => $db_host }
    $default_authenticator = {
      'class'           => 'CASServer::Authenticators::SQLEncrypted',
      'username_column' => 'username',
      'user_table'      => 'users',
      'database'        => {
        'reconnect' => true,
        'adapter'   => $db_adapter,
        'database'  => $db_database,
        'username'  => $db_username,
        'password'  => $db_password,
        'host'      => $use_db_host,
      },
    }
  } elsif ($db_database or $db_username or $db_password) {
    fail('either pass all of db_database, db_username, db_password, or none')
  }

  # Build the authenticator array
  $raw_authenticator_array = [
    $default_authenticator,
    $authenticators,
  ]
  $authenticator_array = reject($raw_authenticator_array, '')

  # Configure the authenticators, if any are specified
  if (size($authenticator_array) > 0) {
    yaml_setting { 'pe_console-cas_server-authenticator':
      key   => 'authenticator',
      type  => 'array',
      value => $authenticator_array,
    }
  }

  # include other settings
  class { 'pe_console::cas_server::config':
    config  => $config,
    require => File[$config],
  }

}
