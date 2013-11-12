class pe_mcollective::role::console (
  $mcollective_enable_stomp_ssl  = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_password                = $pe_mcollective::params::stomp_password,
  $stomp_port                    = $pe_mcollective::params::stomp_port,
  $stomp_servers                 = $pe_mcollective::params::stomp_servers,
  $stomp_user                    = $pe_mcollective::params::stomp_user,
) inherits pe_mcollective::params {

  if ! $is_pe {
    fail($pe_mcollective::params::fail_nonpe_agent)
  }
  if $::osfamily == 'Windows' {
    fail("The console role cannot be applied on a ${::osfamily} platform")
  }

  class { 'pe_mcollective::client::puppet_dashboard':
    mcollective_enable_stomp_ssl  => $mcollective_enable_stomp_ssl,
    stomp_password                => $stomp_password,
    stomp_port                    => $stomp_port,
    stomp_servers                 => $stomp_servers,
    stomp_user                    => $stomp_user,
  }
}
