class pe_console::cas_server::config (
  $config,
) {

  Yaml_setting {
    target  => $config,
    notify  => Service['pe-httpd'],
    require => Package['pe-rubycas-server'],
    before  => Exec['generate_cas_server_session_secret'],
  }

  yaml_setting { 'pe_console-cas_server-custom_views':
    key   => 'custom_views',
    value => '/opt/puppet/share/console-auth/views',
  }
  yaml_setting { 'pe_console-cas_server-public_dir':
    key   => 'public_dir',
    value => '/opt/puppet/share/console-auth/public',
  }
  yaml_setting { 'pe_console-cas_server-default_locale':
    key   => 'default_locale',
    value => 'en',
  }

  yaml_setting { 'pe_console-cas_server-log-file':
    key   => 'log/file',
    value => '/var/log/pe-console-auth/cas.log',
  }
  yaml_setting { 'pe_console-cas_server-log-level':
    key   => 'log/level',
    value => 'INFO',
  }

  yaml_setting { 'pe_console-cas_server-enable_single_sign_out':
    key   => 'enable_single_sign_out',
    value => true,
  }

  yaml_setting { 'pe_console-cas_server-maximum_unused_login_ticket_lifetime':
    key   => 'maximum_unused_login_ticket_lifetime',
    type  => 'integer',
    value => '300',
  }
  yaml_setting { 'pe_console-cas_server-maximum_unused_service_ticket_lifetime':
    key   => 'maximum_unused_service_ticket_lifetime',
    type  => 'integer',
    value => '300',
  }
  yaml_setting { 'pe_console-cas_server-maximum_session_lifetime':
    key   => 'maximum_session_lifetime',
    type  => 'integer',
    value => '1200',
  }

  ## The session secret is randomly generated
  $generate_shell_command = join([
    'dd if=/dev/urandom count=140 2> /dev/null', '|',
    'LC_ALL=C tr -cd "[:xdigit:]"', '|',
    'head -c 128 2>/dev/null', '|',
    "sed -e 's/^/session_secret: /' -e 's/$/\\n/'", '>>',
    $config,
  ], ' ')
  exec { 'generate_cas_server_session_secret':
    path     => '/usr/bin:/bin:/opt/puppet/bin',
    command  => $generate_shell_command,
    unless   => "egrep '^(  )?session_secret: ' ${config}",
    provider => shell,
    require  => File[$config],
  }

}
