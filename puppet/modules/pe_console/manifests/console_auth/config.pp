class pe_console::console_auth::config (
  $console_absolute_url,
  $smtp_host,
  $smtp_port,
  $smtp_username,
  $smtp_password,
  $auth_cas_url      = '/cas',
  $auth_service_url  = '/',
  $log_client_file   = '/var/log/pe-console-auth/cas_client.log',
  $log_file          = '/var/log/pe-console-auth/auth.log',
  $log_level         = 'INFO',
) {
  include pe_httpd
  include pe_console

  Yaml_setting {
    target  => '/etc/puppetlabs/console-auth/config.yml',
    notify  => Service['pe-httpd'],
    require => File['/etc/puppetlabs/console-auth/config.yml'],
  }

  yaml_setting { 'pe_console-auth-config-smtp_host':
    key   => 'smtp/address',
    value => $smtp_host,
  }
  yaml_setting { 'pe_console-auth-config-smtp_port':
    key   => 'smtp/port',
    type  => 'integer',
    value => $smtp_port,
  }

  if $smtp_password {
    yaml_setting { 'pe_console-auth-config-smtp_username':
      nodisplay => true,
      key       => 'smtp/username',
      value     => $smtp_username,
    }
  }
  if $smtp_username {
    yaml_setting { 'pe_console-auth-config-smtp_password':
      key   => 'smtp/username',
      value => $smtp_password,
    }
  }
  if $console_absolute_url {
    yaml_setting { 'pe_console-auth-config-authentication-console_absolute_url':
      key   => 'authentication/console_absolute_url',
      value => $console_absolute_url,
    }
  }

  yaml_setting { 'pe_console-auth-config-auth_cas_url':
    key   => 'authentication/cas_url',
    value => $auth_cas_url,
  }
  yaml_setting { 'pe_console-auth-config-auth_service_url':
    key   => 'authentication/service_url',
    value => $auth_service_url,
  }
  yaml_setting { 'pe_console-auth-config-auth_validate_url':
    key   => 'authentication/validate_url',
    value => "https://${console_absolute_url}:443/cas/proxyValidate",
  }
  yaml_setting { 'pe_console-auth-config-log_client_file':
    key   => 'log/client_file',
    value => $log_client_file,
  }
  yaml_setting { 'pe_console-auth-config-log_file':
    key   => 'log/file',
    value => $log_file,
  }
  yaml_setting { 'pe_console-auth-config-log_level':
    key   => 'log/level',
    value => $log_level,
  }

}
