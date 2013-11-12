class pe_mcollective::activemq (
  $activemq_brokername          = undef,
  $activemq_brokers             = $pe_mcollective::params::activemq_brokers,
  $activemq_heap_mb             = $pe_mcollective::params::activemq_heap_mb,
  $activemq_network_ttl         = $pe_mcollective::params::activemq_network_ttl,
  $mcollective_enable_stomp_ssl = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_password               = $pe_mcollective::params::stomp_password,
  $stomp_port                   = $pe_mcollective::params::stomp_port,
  $stomp_user                   = $pe_mcollective::params::stomp_user,
) inherits pe_mcollective::params {
  $stomp_activemq_protocol = $mcollective_enable_stomp_ssl ? {
    true  => 'stomp+ssl',
    false => 'stomp+nio',
  }
  $openwire_activemq_protocol = $mcollective_enable_stomp_ssl ? {
    true  => 'ssl',
    false => 'tcp',
  }
  $_activemq_brokername = pick($activemq_brokername, $::clientcert)

  package { 'pe-activemq':
    ensure => installed,
    before => Service['pe-activemq'],
  }

  # Make sure ActiveMQ is running
  service { 'pe-activemq':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require => [ File['/etc/puppetlabs/activemq/activemq.xml'] ],
  }

  # Make sure activemq is aware of the stomp password
  # Template uses:
  # - $osfamily (fact)
  # - $activemq_brokers
  # - $_activemq_brokername
  # - $activemq_network_ttl
  # - $mcollective_enable_stomp_ssl
  # - $openwire_activemq_protocol
  # - $stomp_activemq_protocol
  # - $stomp_user
  # - $stomp_password
  # - $stomp_port
  file { '/etc/puppetlabs/activemq/activemq.xml':
    ensure  => file,
    content => template("${module_name}/activemq.xml.erb"),
    owner   => '0',
    group   => 'pe-activemq',
    mode    => '0640',
    require => Package['pe-activemq'],
    notify  => Service['pe-activemq'],
  }

  # Configure the ActiveMQ Wrapper in case we've enabled SSL.
  # Template uses:
  # - $osfamily (fact)
  # - $puppetversion (fact)
  # - $activemq_heap_mb
  file { '/etc/puppetlabs/activemq/activemq-wrapper.conf':
    ensure  => file,
    content => template("${module_name}/activemq-wrapper.conf.erb"),
    owner   => '0',
    group   => '0',
    mode    => '0644',
    require => Package['pe-activemq'],
    notify  => Service['pe-activemq'],
  }
}
