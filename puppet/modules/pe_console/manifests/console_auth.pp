class pe_console::console_auth (
  $db_host,
  $db_password,
  $db_port              = undef,
  $db_database          = 'console_auth',
  $db_username          = 'console_auth',
  $db_adapter           = 'postgresql',
  $db_timeout           = '5000',
  $smtp_host            = 'localhost',
  $smtp_port            = 25,
  $smtp_tls             = 'true',
  $smtp_username        = undef,
  $smtp_password        = undef,
  $console_absolute_url = undef,
  $login_username       = undef,
  $login_password       = undef,
  $console_auth_root    = '/opt/puppet/share/console-auth',
) {
  include pe_console

  package { 'pe-console-auth':
    ensure  => installed,
    require => Package['pe-console'],
    before  => [
      Class['pe_console::console_auth::config'],
      Class['pe_console::console_auth::database'],
      Pe_console::Rake_task['puppet-console_auth-dbmigrate'],
    ],
  }

  file { '/var/log/pe-console-auth':
    ensure  => directory,
    owner   => 'pe-auth',
    group   => 'puppet-dashboard',
    mode    => '0770',
    notify  => Service['pe-httpd'],
    require => Package['pe-console-auth'],
  }
  file { '/var/log/pe-console-auth/auth.log':
    ensure  => file,
    owner   => 'pe-auth',
    group   => 'puppet-dashboard',
    mode    => '0660',
    require => Package['pe-console-auth'],
  }
  file { '/etc/puppetlabs/console-auth/database.yml':
    ensure  => file,
    owner   => 'pe-auth',
    group   => 'puppet-dashboard',
    mode    => '0440',
    require => Package['pe-console-auth'],
  }
  file { '/etc/puppetlabs/console-auth/config.yml':
    ensure  => file,
    owner   => 'pe-auth',
    group   => 'puppet-dashboard',
    mode    => '0640',
    replace => false,
    content => template('pe_console/console_auth/config.yml.erb'),
    require => Package['pe-console-auth'],
  }

  class { 'pe_console::console_auth::config':
    smtp_host            => $smtp_host,
    smtp_port            => $smtp_port,
    smtp_username        => $smtp_username,
    smtp_password        => $smtp_password,
    console_absolute_url => $console_absolute_url,
  }

  class { 'pe_console::console_auth::database':
    host       => $db_host,
    password   => $db_password,
    port       => $db_port,
    database   => $db_database,
    username   => $db_username,
    adapter    => $db_adapter,
    timeout    => $db_timeout,
  }

  pe_console::rake_task { 'puppet-console_auth-dbmigrate':
    task        => 'db:migrate',
    rakefile    => "${console_auth_root}/Rakefile",
    refreshonly => true,
    subscribe   => Class['pe_console::console_auth::database'],
  }

  if ($login_username and $login_password) {
    pe_console::rake_task { 'puppet-console_auth-login_user':
      task        => "db:create_user USERNAME='${login_username}' PASSWORD='${login_password}' ROLE='Admin'",
      rakefile    => "${console_auth_root}/Rakefile",
      refreshonly => true,
      require     => Pe_console::Rake_task['puppet-console_auth-dbmigrate'],
      subscribe   => Class['pe_console::console_auth::database'],
    }
  }

}
