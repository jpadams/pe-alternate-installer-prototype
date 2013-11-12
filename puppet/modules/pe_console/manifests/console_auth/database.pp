class pe_console::console_auth::database (
  $password,
  $adapter,
  $database,
  $username,
  $host,
  $port,
  $timeout,
) {
  include pe_httpd
  include pe_console

  Yaml_setting {
    target  => '/etc/puppetlabs/console-auth/database.yml',
    notify  => Service['pe-httpd'],
    require => File['/etc/puppetlabs/console-auth/database.yml'],
  }

  yaml_setting { 'pe_console-auth-db-password':
    nodisplay => true,
    key       => 'production/password',
    value     => $password,
  }
  yaml_setting { 'pe_console-auth-db-adapter':
    key   => 'production/adapter',
    value => $adapter,
  }
  yaml_setting { 'pe_console-auth-db-timeout':
    key   => 'production/timeout',
    value => $timeout,
  }
  yaml_setting { 'pe_console-auth-db-database':
    key   => 'production/database',
    value => $database,
  }
  yaml_setting { 'pe_console-auth-db-username':
    key   => 'production/username',
    value => $username,
  }

  if $port {
    yaml_setting { 'pe_console-auth-db-db_port':
      key   => 'production/port',
      type  => 'integer',
      value => $port,
    }
  }

  if $host {
    yaml_setting { 'pe_console-auth-db-db_host':
      key   => 'production/host',
      value => $host,
    }
  }

}
