class pe_console::cas_client (
  $config_file = '/etc/puppetlabs/console-auth/cas_client_config.yml',
) {
  include pe_httpd

  Yaml_setting {
    target  => $config_file,
    notify  => Service['pe-httpd'],
    require => Package['pe-rubycas-server'],
    before  => Exec['generate_cas_client_session_secret'],
  }

  file { '/var/log/pe-console-auth/cas_client.log':
    ensure => file,
    owner  => 'pe-auth',
    group  => 'puppet-dashboard',
    mode   => '0660',
  }

  file { $config_file:
    ensure => file,
    owner  => 'pe-auth',
    group  => 'puppet-dashboard',
    mode   => '0640',
  }

  yaml_setting { 'cas_client_config-auth-session_key':
    key   => 'authentication/session_key',
    value => 'puppet_enterprise_console',
  }
  yaml_setting { 'cas_client_config-auth-session_timeout':
    key   => 'authentication/session_timeout',
    type  => 'integer',
    value => '1200',
  }
  yaml_setting { 'cas_client_config-auth-global_unauthenticated_access':
    key   => 'authentication/global_unauthenticated_access',
    value => false,
  }

  yaml_setting { 'cas_client_config-authorize-local-default_role':
    key   => 'authorization/local/default_role',
    value => 'read-only',
  }
  yaml_setting { 'cas_client_config-authorize-local-description':
    key   => 'authorization/local/description',
    value => 'local',
  }

  ## The session secret is randomly generated
  $random_command = join([
    'dd if=/dev/urandom count=140 2> /dev/null', '|',
    'LC_ALL=C tr -cd "[:xdigit:]"', '|',
    'head -c 128 2>/dev/null',
  ], ' ')
  $insert_command = join([
    "sed -i \"s/\\( *\\)\\(session_key: .*\\)/\\1\\2\\n\\1session_secret: `${random_command}`/\"",
    $config_file,
  ], ' ')
  exec { 'generate_cas_client_session_secret':
    path     => '/usr/bin:/bin:/opt/puppet/bin',
    command  => $insert_command,
    unless   => "egrep '^( *)?session_secret: ' ${config_file}",
    provider => shell,
    require  => Yaml_setting['cas_client_config-auth-session_key'],
  }

}
