class pe_mcollective::shared_key_files {
  # Configure the AES keys for each mcollective server (Note, these are not
  # actually used as SSL certificates, they're just used for their public and
  # private keys if AES security is enabled.)
  #
  # Note that all file resources declared here are virtual. They will be
  # realized in other pe_mcollective classes based on tags.

  File {
    ensure => file,
    owner  => $pe_mcollective::params::root_owner,
    group  => $pe_mcollective::params::root_group,
    mode   => $pe_mcollective::params::root_mode,
  }

  $mode_755 = $::osfamily ? {
    'windows' => '0775',
    default   => '0755'
  }
  $mode_600 = $::osfamily ? {
    'windows' => '0660',
    default   => '0600'
  }

  # Common directories
  @file { "${pe_mcollective::params::mco_etc}/ssl":
    ensure => directory,
    mode   => $mode_755,
    notify => Service['pe-mcollective'],
    tag    => ['pe_mco_server'],
  }
  @file { "${pe_mcollective::params::mco_etc}/ssl/clients":
    ensure => directory,
    mode   => $mode_755,
    tag    => ['pe_mco_server'],
  }

  # MCollective server key files
  @file { 'mcollective-public.pem':
    path    => "${pe_mcollective::params::mco_etc}/ssl/mcollective-public.pem",
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem', '/dev/null'),
    notify  => Service['pe-mcollective'],
    tag     => ['pe_mco_server'],
  }
  @file { 'mcollective-private.pem':
    path    => "${pe_mcollective::params::mco_etc}/ssl/mcollective-private.pem",
    content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-mcollective-servers.pem', '/dev/null'),
    mode    => $mode_600,
    notify  => Service['pe-mcollective'],
    tag     => ['pe_mco_server'],
  }
  @file { 'mcollective-cert.pem':
    path    => "${pe_mcollective::params::mco_etc}/ssl/mcollective-cert.pem",
    content => file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-mcollective-servers.pem', '/dev/null'),
    notify  => Service['pe-mcollective'],
    tag     => ['pe_mco_server'],
  }
  @file { 'mcollective-cacert.pem':
    path    => "${pe_mcollective::params::mco_etc}/ssl/mcollective-cacert.pem",
    content => file('/etc/puppetlabs/puppet/ssl/certs/ca.pem', '/dev/null'),
    notify  => Service['pe-mcollective'],
    tag     => ['pe_mco_server'],
  }

  # Public key files for pe_mcollective clients (peadmin, puppet-dashboard)
  @file { 'peadmin-public.pem':
    path    => "${pe_mcollective::params::mco_etc}/ssl/clients/peadmin-public.pem",
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem', '/dev/null'),
    notify  => Service['pe-mcollective'],
    tag     => ['pe_mco_server'],
  }
  @file { 'puppet-dashboard-public.pem':
    path    => "${pe_mcollective::params::mco_etc}/ssl/clients/puppet-dashboard-public.pem",
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem', '/dev/null'),
    notify  => Service['pe-mcollective'],
    tag     => ['pe_mco_server'],
  }

  # PE Console key files (for the puppet-dashboard mcollective client)
  @file { '/var/lib/peadmin/.mcollective.d/peadmin-private.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-peadmin-mcollective-client.pem', '/dev/null'),
    owner   => 'peadmin',
    group   => 'peadmin',
    mode    => '0600',
    tag     => ['pe_mco_client_peadmin'],
  }
  @file { '/var/lib/peadmin/.mcollective.d/peadmin-public.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-peadmin-mcollective-client.pem', '/dev/null'),
    owner   => 'peadmin',
    group   => 'peadmin',
    tag     => ['pe_mco_client_peadmin'],
  }
  @file { '/var/lib/peadmin/.mcollective.d/peadmin-cert.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-peadmin-mcollective-client.pem', '/dev/null'),
    owner   => 'peadmin',
    group   => 'peadmin',
    tag     => ['pe_mco_client_peadmin'],
  }
  @file { '/var/lib/peadmin/.mcollective.d/peadmin-cacert.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/certs/ca.pem', '/dev/null'),
    owner   => 'peadmin',
    group   => 'peadmin',
    tag     => ['pe_mco_client_peadmin'],
  }
  @file { '/var/lib/peadmin/.mcollective.d/mcollective-public.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem', '/dev/null'),
    owner   => 'peadmin',
    group   => 'peadmin',
    tag     => ['pe_mco_client_peadmin'],
  }

  @file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-private.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/private_keys/pe-internal-puppet-console-mcollective-client.pem', '/dev/null'),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0600',
    tag     => ['pe_mco_client_puppet_dashboard'],
  }
  @file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-public.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-puppet-console-mcollective-client.pem', '/dev/null'),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    tag     => ['pe_mco_client_puppet_dashboard'],
  }
  @file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cert.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/certs/pe-internal-puppet-console-mcollective-client.pem', '/dev/null'),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    tag     => ['pe_mco_client_puppet_dashboard'],
  }
  @file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cacert.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/certs/ca.pem', '/dev/null'),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    tag     => ['pe_mco_client_puppet_dashboard'],
  }
  @file { '/opt/puppet/share/puppet-dashboard/.mcollective.d/mcollective-public.pem':
    ensure  => file,
    content => file('/etc/puppetlabs/puppet/ssl/public_keys/pe-internal-mcollective-servers.pem', '/dev/null'),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    tag     => ['pe_mco_client_puppet_dashboard'],
  }
}
