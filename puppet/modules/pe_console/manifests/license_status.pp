class pe_console::license_status (
  $ssl_keyfile,
  $ssl_certfile,
  $ssl_cacertfile,
  $puppetdb_host,
  $puppetdb_port  = '8081',
  $licenses_root  = '/opt/puppet/share/console/applications/licenses',
) {

  package { 'pe-license-status':
    ensure => $pe_licensestatus_version,
  }

  file { "${licenses_root}":
    ensure  => directory,
    require => Package['pe-license-status'],
  }
  file { "${licenses_root}/config.yml":
    ensure => file,
    require => Package['pe-license-status'],
  }

  Yaml_setting {
    target  => "${licenses_root}/config.yml",
    require => File["${licenses_root}/config.yml"],
    notify  => Service['pe-puppet-dashboard-workers'],
  }

  yaml_setting { 'licenses-ssl-key':
    key     => 'ssl/key',
    value   => $ssl_keyfile,
  }
  yaml_setting { 'licenses-ssl-cert':
    key     => 'ssl/cert',
    value   => $ssl_certfile,
  }
  yaml_setting { 'licenses-ssl-cacert':
    key     => 'ssl/cacert',
    value   => $ssl_cacertfile,
  }
  yaml_setting { 'licenses-puppetdb-host':
    key     => 'puppetdb/host',
    value   => $puppetdb_host,
  }
  yaml_setting { 'licenses-puppetdb-port':
    key     => 'puppetdb/port',
    value   => $puppetdb_port,
  }

}
