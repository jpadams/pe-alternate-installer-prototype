class pe_mcollective::ca (
  $mcollective_enable_stomp_ssl = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_servers                = $pe_mcollective::params::stomp_servers,
) inherits pe_mcollective::params {

  # Create shared keys for use on all mcollective servers. Most nodes will
  # source these from the pe_mcollective::ca node and the data will be sent
  # as a content parameter in the catalog. On the ca node, we will instead
  # source the files directly from their location on disk.
  include pe_mcollective::shared_key_files::ca
  File <| tag == 'pe_mco_ca' |>

  file { 'credentials':
    path    => '/etc/puppetlabs/mcollective/credentials',
    owner   => 'pe-puppet',
    group   => 'pe-puppet',
    mode    => '0600',
    content => $pe_mcollective::params::stomp_password,
  }

  # Make sure we have a shared certificate for all of the MC servers
  pe_mcollective::puppet_certificate { 'pe-internal-mcollective-servers': }
  pe_mcollective::puppet_certificate { 'pe-internal-peadmin-mcollective-client': }
  pe_mcollective::puppet_certificate { 'pe-internal-puppet-console-mcollective-client': }

  # Generate the SSL Certificate used by the Stomp Server if SSL is enabled.
  if $mcollective_enable_stomp_ssl {

    # JJM This is here to work around the unlikely event that $::fqdn is an empty string.
    # See: http://goo.gl/hVm0r
    $_fqdn = $::fqdn ? {
      undef   => $::hostname,
      ''      => $::hostname,
      default => $::fqdn,
    }

    # We use Puppet's CA to generate the private key and issue the certificate
    pe_mcollective::puppet_certificate { 'pe-internal-broker':
      dns_alt_names => join(['stomp', $stomp_servers, $_fqdn], ','),
    }

    Java_ks {
      path => [ '/opt/puppet/bin', '/usr/bin', '/bin', '/usr/sbin', '/sbin' ],
    }

    java_ks { 'puppetca:truststore':
      ensure       => latest,
      certificate  => '/etc/puppetlabs/puppet/ssl/certs/ca.pem',
      target       => '/etc/puppetlabs/activemq/broker.ts',
      password     => 'puppet',
      trustcacerts => true,
      require      => Pe_mcollective::Puppet_certificate['pe-internal-broker'],
      before       => File['/etc/puppetlabs/activemq/broker.ts'],
      notify       => Service['pe-activemq'],
    }
    java_ks { "${stomp_servers}:keystore":
      ensure      => latest,
      target      => '/etc/puppetlabs/activemq/broker.ks',
      certificate => '/etc/puppetlabs/puppet/ssl/certs/pe-internal-broker.pem',
      private_key => '/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-broker.pem',
      password    => 'puppet',
      require     => Pe_mcollective::Puppet_certificate['pe-internal-broker'],
      before      => File['/etc/puppetlabs/activemq/broker.ks'],
      notify      => Service['pe-activemq'],
    }

    # These files are resources too so that owner/group/mode can be ensured
    file { '/etc/puppetlabs/activemq/broker.ks':
      ensure => file,
      owner  => '0',
      group  => 'pe-activemq',
      mode   => '0640',
    }
    file { '/etc/puppetlabs/activemq/broker.ts':
      ensure => file,
      owner   => '0',
      group   => 'pe-activemq',
      mode    => '0640',
    }
  }
}
