class pe_console::dashboard (
  $db_host,
  $db_password,
  $filebucket_host,
  $certname          = "pe-internal-dashboard.${::clientcert}",
  $db_port           = '3306',
  $db_database       = 'console',
  $db_username       = 'console',
  $inventory_host    = 'puppetinventory',
  $inventory_port    = '8140',
  $filebucket_port   = '8140',
  $ca_host           = 'puppetca',
  $ca_port           = '8140',
  $dashboard_root    = '/opt/puppet/share/puppet-dashboard',
  $console_host      = '*',
  $console_port      = '443',
  $waitforcert       = '120',
  $no_longer_reporting_cutoff = '3600',
  $dashboard_version      = installed,
) {
  include pe_httpd
  include pe_console

  File {
    ensure  => file,
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0640',
    notify  => Service['pe-httpd'],
    require => Package['pe-puppet-dashboard'],
  }

  package { 'pe-puppet-dashboard':
    ensure => $dashboard_version,
  }

  file { '/var/log/pe-puppet-dashboard':
    ensure  => directory,
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0770',
    notify  => Service['pe-httpd'],
    require => Package['pe-puppet-dashboard'],
  }

  file { '/var/log/pe-puppet-dashboard/delayed_job.log':
    ensure => file,
    notify => Service['pe-puppet-dashboard-workers'],
  }
  file { "${dashboard_root}/log/production.log":
    ensure  => file,
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0660',
    require => Package['pe-puppet-dashboard'],
  }
  if $::osfamily == 'Debian' {
    # Debian needs extra enabling
    file_line { 'enable-puppet-dashboard-workers':
      ensure => present,
      path   => '/etc/default/pe-puppet-dashboard-workers',
      match  => 'START=',
      line   => 'START=yes',
      before => Service['pe-puppet-dashboard-workers'],
    }
  }

  service { 'pe-puppet-dashboard-workers':
    ensure    => running,
    enable    => true,
    subscribe => Service['pe-httpd'],
    require   => [
      File['/var/log/pe-console-auth/auth.log'],
      File['/etc/puppetlabs/console-auth/database.yml'],
      Package['pe-console'],
    ],
  }

  # Configuration files for the application
  file { '/etc/puppetlabs/puppet-dashboard':
    ensure => directory,
    mode   => '0750',
  }
  file { '/etc/puppetlabs/puppet-dashboard/settings.yml':
    content => template('pe_console/settings.yml.erb'),
    require => Puppet_certificate[$certname],
    before  => Pe_console::Rake_task['puppet-dashboard-dbmigrate'],
  }
  file { '/etc/puppetlabs/puppet-dashboard/database.yml':
    content => template('pe_console/database.yml.erb'),
    before  => Pe_console::Rake_task['puppet-dashboard-dbmigrate'],
  }

  # Set up the dashboard database
  pe_console::rake_task { 'puppet-dashboard-dbmigrate':
    task        => 'db:migrate',
    unless_task => "db:migrate:status | grep 'database: ${db_database}'",
    require     => Package['pe-console'],
    notify      => Service['pe-httpd'],
  }

  pe_httpd::vhost { 'puppetdashboard':
    content => template('pe_console/puppetdashboard.conf.erb'),
    require => [
      File["${dashboard_root}/certs/${certname}.ca_crl.pem"],
      File["${dashboard_root}/certs/${certname}.ca_cert.pem"],
      File["${dashboard_root}/certs/${certname}.cert.pem"],
      File["${dashboard_root}/certs/${certname}.private_key.pem"],
      File["${dashboard_root}/certs/${certname}.public_key.pem"],
    ],
  }

  # Certificate files used by the application
  puppet_certificate { $certname:
    ensure      => present,
    waitforcert => $waitforcert,
  }
  file { "${dashboard_root}/certs":
    ensure => directory,
    mode   => '0750',
  }
  file { "${dashboard_root}/certs/${certname}.ca_crl.pem":
    source  => '/etc/puppetlabs/puppet/ssl/crl.pem',
    require => Puppet_certificate[$certname],
  }
  file { "${dashboard_root}/certs/${certname}.ca_cert.pem":
    source  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
    require => Puppet_certificate[$certname],
  }
  file { "${dashboard_root}/certs/${certname}.cert.pem":
    source  => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    require => Puppet_certificate[$certname],
  }
  file { "${dashboard_root}/certs/${certname}.private_key.pem":
    source  => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    require => Puppet_certificate[$certname],
  }
  file { "${dashboard_root}/certs/${certname}.public_key.pem":
    source  => "/etc/puppetlabs/puppet/ssl/public_keys/${certname}.pem",
    require => Puppet_certificate[$certname],
  }

}
