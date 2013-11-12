class pe_console::event_inspector (
  $ssl_keyfile,
  $ssl_certfile,
  $ssl_cacertfile,
  $puppetdb_host,
  $puppetdb_port,
  $version             = installed,
  $eventinspector_root = '/opt/puppet/share/event-inspector',
) {

  package { 'pe-event-inspector':
    ensure => $version,
  }

  file { "${eventinspector_root}/config/config.yml":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  file { '/var/log/pe-puppet-dashboard/event-inspector.log':
    ensure => file,
    owner  => 'puppet-dashboard',
    group  => 'puppet-dashboard',
    mode   => '0644',
  }

  Yaml_setting {
    ensure => present,
    target => "${eventinspector_root}/config/config.yml",
    notify => Service['pe-httpd'],
  }

  yaml_setting { 'ei-base_url':
    key     => 'base_url',
    value   => 'events/',
  }
  yaml_setting { 'ei-console_base_url':
    key     => 'console_base_url',
    value   => '/',
  }
  yaml_setting { 'ei-puppetdb-pem-ca_file':
    key     => 'puppetdb/pem/ca_file',
    value   => $ssl_cacertfile,
  }
  yaml_setting { 'ei-puppetdb-pem-key':
    key     => 'puppetdb/pem/key',
    value   => $ssl_keyfile,
  }
  yaml_setting { 'ei-puppetdb-pem-cert':
    key     => 'puppetdb/pem/cert',
    value   => $ssl_certfile,
  }
  yaml_setting { 'ei-puppetdb-server':
    key     => 'puppetdb/server',
    value   => "https://${puppetdb_host}:${puppetdb_port}"
  }

}
