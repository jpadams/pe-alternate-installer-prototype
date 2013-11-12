class pe_mcollective::role::agent (
  $mcollective_enable_stomp_ssl  = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_password                = $pe_mcollective::params::stomp_password,
  $stomp_port                    = $pe_mcollective::params::stomp_port,
  $stomp_servers                 = $pe_mcollective::params::stomp_servers,
  $stomp_user                    = $pe_mcollective::params::stomp_user,
  $warn_on_nonpe_agents          = true,
  $warn_on_nonpe3_agents         = true,
  $mcollective_registerinterval  = $pe_mcollective::params::mcollective_registerinterval,
) inherits pe_mcollective::params {

  if $pe_mcollective::params::is_pe and $::pe_major_version == '3' {
    class { 'pe_mcollective::server':
      mcollective_enable_stomp_ssl => $mcollective_enable_stomp_ssl,
      stomp_user                   => $stomp_user,
      stomp_password               => $stomp_password,
      stomp_servers                => $stomp_servers,
      stomp_port                   => $stomp_port,
      mcollective_registerinterval => $mcollective_registerinterval,
    }
  } elsif ! $pe_mcollective::params::is_pe and $warn_on_nonpe_agents {
    notify { 'pe_mcollective-un_supported_platform':
      message => $pe_mcollective::params::warn_nonpe_agent,
    }
  } elsif $::pe_major_version != '3' and $warn_on_nonpe3_agents {
    notify { 'pe_mcollective-non_pe_3_agent':
      message => $pe_mcollective::params::warn_nonpe3_agent,
    }
  }

}
