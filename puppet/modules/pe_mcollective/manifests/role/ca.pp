class pe_mcollective::role::ca (
  $activemq_brokername           = undef,
  $activemq_brokers              = $pe_mcollective::params::activemq_brokers,
  $activemq_heap_mb              = $pe_mcollective::params::activemq_heap_mb,
  $activemq_network_ttl          = $pe_mcollective::params::activemq_network_ttl,
  $mcollective_enable_stomp_ssl  = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_password                = $pe_mcollective::params::stomp_password,
  $stomp_port                    = $pe_mcollective::params::stomp_port,
  $stomp_servers                 = $pe_mcollective::params::stomp_servers,
  $stomp_user                    = $pe_mcollective::params::stomp_user,
) inherits pe_mcollective::role::master {

  class { 'pe_mcollective::ca':
    mcollective_enable_stomp_ssl => $mcollective_enable_stomp_ssl,
    stomp_servers                => $stomp_servers,
  }
  class { 'pe_mcollective::activemq':
    activemq_brokername          => $activemq_brokername,
    activemq_brokers             => $activemq_brokers,
    activemq_heap_mb             => $activemq_heap_mb,
    activemq_network_ttl         => $activemq_network_ttl,
    mcollective_enable_stomp_ssl => $mcollective_enable_stomp_ssl,
    stomp_user                   => $stomp_user,
    stomp_password               => $stomp_password,
    stomp_port                   => $stomp_port,
  }

}
