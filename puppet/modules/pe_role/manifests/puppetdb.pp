class pe_role::puppetdb (
  $ssl_listen_address = '0.0.0.0',
  $ssl_listen_port    = undef,
  $database_host      = $pe_role::puppetdb_db,
  $database_port      = undef,
  $database_username  = $pe_role::puppetdb_username,
  $database_password  = $pe_role::puppetdb_password,
  $dns_alt_names      = $pe_role::puppetdb,
  $default_whitelist  = [
    "${pe_role::puppetmaster_cert_prefix}.${pe_role::puppetmaster}",
    "${pe_role::puppetconsole_cert_prefix}.${pe_role::puppetconsole}",
  ],
) inherits pe_role {

  class { 'pe_puppetdb':
    require            => Anchor['pe_role::setup_database'],
    ssl_listen_address => $ssl_listen_address,
    ssl_listen_port    => $ssl_listen_port,
    database_host      => $database_host,
    database_port      => $database_port,
    database_name      => $database_name,
    database_username  => $database_username,
    database_password  => $database_password,
    dns_alt_names      => $dns_alt_names,
  }

  file { '/etc/puppetlabs/puppetdb/certificate-whitelist':
    require => Anchor['pe_role::setup_database'],
    ensure  => present,
    owner   => 'pe-puppetdb',
    group   => 'pe-puppetdb',
    mode    => '0600',
  }

  # Create whitelist entries for each element of $default_whitelist
  pe_role::util::puppetdb_whitelist { $default_whitelist:
    ensure  => present,
    require => Anchor['pe_role::setup_database'],
  }

  # Collect exported entries for the whitelist
  Pe_role::Util::Puppetdb_whitelist <<| tag == 'pe_role' |>> {
    require => Anchor['pe_role::setup_database'],
  }

  ini_setting { 'puppetdb-certificate-whitelist':
    require => Anchor['pe_role::setup_database'],
    ensure  => present,
    path    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
    section => jetty,
    setting => 'certificate-whitelist',
    value   => '/etc/puppetlabs/puppetdb/certificate-whitelist',
    notify  => Service['pe-puppetdb'],
  }

}
