# Class: pe_puppetdb
#
# This class is a wrapper for puppetdb and pe_postgresql modules.
# It provides a simple way to get a PE puppetdb instance up and running
# within Puppet Enterprise.  It will install and configure all necessary packages,
# including the database PostgreSQL server and instance.
#
# In addition to this class, you'll need to configure your puppet master to use
# puppetdb.  You can use the `puppetdb::master::config` class to accomplish this.
#
# Parameters:
#   ['listen_address']     - The address that the web server should bind to
#                            for HTTP requests.  (defaults to `localhost`.
#                            '0.0.0.0' = all)
#   ['listen_port']        - The port on which the puppetdb web server should
#                            accept HTTP requests (defaults to 8080).
#   ['open_listen_port']   - If true, open the http listen port on the firewall. 
#                            (defaults to false).
#   ['ssl_listen_address'] - The address that the web server should bind to
#                            for HTTPS requests.  (defaults to `$::clientcert`.)
#                            Set to '0.0.0.0' to listen on all addresses.
#   ['ssl_listen_port']    - The port on which the puppetdb web server should
#                            accept HTTPS requests (defaults to 8081).
#   ['open_ssl_listen_port'] - If true, open the ssl listen port on the firewall. 
#                            (defaults to true).
#   ['database']           - Which database backend to use; legal values are
#                            `postgres` (default) or `embedded`.  (The `embedded`
#                            db can be used for very small installations or for
#                            testing, but is not recommended for use in production
#                            environments.  For more info, see the puppetdb docs.)
#   ['database_port']      - The port that the database server listens on.
#                            (defaults to `5432`; ignored for `embedded` db)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `puppetdb`; ignored for `embedded` db)
#   ['database_password']  - The password for the database user.
#                            (defaults to `puppetdb`; ignored for `embedded` db)
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `puppetdb`; ignored for `embedded` db)
#   ['tablespace_name']    - The name of puppetdb tablespace.
#   ['tablespace_location']- The location of puppetdb tablespace.
#   ['manage_database']    - Whether to manage the Postgres database. Defaults
#                            to true, can be set to false if the database is
#                            remote and already exists.
#   ['puppetdb_package']   - The puppetdb package name in the package manager
#   ['puppetdb_version']   - The version of the `puppetdb` package that should
#                            be installed.  You may specify an explicit version
#                            number, 'present', or 'latest'.  (defaults to
#                            'present')
#   ['puppetdb_service']   - The name of the puppetdb service.
#   ['confdir']            - The puppetdb configuration directory; defaults to
#                            `/etc/puppetdb/conf.d`.
# Actions:
# - Creates and manages a puppetdb server and its database server/instance.
#
# Requires:
# - `puppetlabs/puppetlabs-pe_postgresql`
#
# Sample Usage:
#   include pe_puppetdb
#
class pe_puppetdb(
  $listen_address            = $puppetdb::params::listen_address,
  $listen_port               = $puppetdb::params::listen_port,
  $open_listen_port          = $puppetdb::params::open_listen_port,
  $ssl_listen_address        = $puppetdb::params::ssl_listen_address,
  $ssl_listen_port           = $puppetdb::params::ssl_listen_port,
  $open_ssl_listen_port      = $puppetdb::params::open_ssl_listen_port,
  $database_host             = $pe_puppetdb::params::database_host,
  $database_port             = $pe_puppetdb::params::database_port,
  $database_username         = $pe_puppetdb::params::database_username,
  $database_password         = $pe_puppetdb::params::database_password,
  $database_name             = $pe_puppetdb::params::database_name,
  $tablespace_name           = $pe_puppetdb::params::tablespace_name,
  $tablespace_location       = $pe_puppetdb::params::tablespace_location,
  $node_ttl                  = $pe_puppetdb::params::node_ttl,
  $puppetdb_package          = $pe_puppetdb::params::puppetdb_package,
  $puppetdb_version          = $puppetdb::params::puppetdb_version,
  $puppetdb_service          = $pe_puppetdb::params::puppetdb_service,
  $confdir                   = $pe_puppetdb::params::confdir,
  $postgres_listen_addresses = undef,
  $certname                  = "pe-internal-puppetdb.${::clientcert}",
  $dns_alt_names             = undef,
  $waitforcert               = '120',
) inherits pe_puppetdb::params {

  $database                  = $pe_puppetdb::params::database

  # Java VM configuration
  $java_args = pe_puppetdb_safe_hiera_hash('pe_puppetdb::java_args', $pe_puppetdb::params::default_jvm_args)

  class { 'puppetdb::server':
    listen_address          => $listen_address,
    listen_port             => $listen_port,
    open_listen_port        => $open_listen_port,
    ssl_listen_address      => $ssl_listen_address,
    ssl_listen_port         => $ssl_listen_port,
    open_ssl_listen_port    => $open_ssl_listen_port,
    database                => $database,
    database_host           => $database_host,
    database_port           => $database_port,
    database_username       => $database_username,
    database_password       => $database_password,
    database_name           => $database_name,
    node_ttl                => $node_ttl,
    puppetdb_package        => $puppetdb_package,
    puppetdb_version        => $puppetdb_version,
    puppetdb_service        => $puppetdb_service,
    confdir                 => $confdir,
    java_args               => $java_args,
  }

  puppet_certificate { $certname:
    ensure        => present,
    dns_alt_names => $dns_alt_names,
    waitforcert   => $waitforcert,
  }

  $puppetdb_jettyini = '/etc/puppetlabs/puppetdb/conf.d/jetty.ini'
  $puppetdb_ssldir   = '/etc/puppetlabs/puppetdb/ssl'
  $puppetdb_sslkey   = "${puppetdb_ssldir}/${certname}.key.pem"
  $puppetdb_sslcert  = "${puppetdb_ssldir}/${certname}.cert.pem"

  file { $puppetdb_ssldir:
    ensure => directory,
    owner  => 'pe-puppetdb',
    group  => 'pe-puppetdb',
    mode   => '0750',
  }
  file { $puppetdb_sslkey:
    ensure  => file,
    owner   => 'pe-puppetdb',
    group   => 'pe-puppetdb',
    mode    => '0640',
    source  => "/etc/puppetlabs/puppet/ssl/private_keys/${certname}.pem",
    require => Puppet_certificate[$certname],
    notify  => Service['pe-puppetdb'],
  }
  file { $puppetdb_sslcert:
    ensure  => file,
    owner   => 'pe-puppetdb',
    group   => 'pe-puppetdb',
    mode    => '0640',
    source  => "/etc/puppetlabs/puppet/ssl/certs/${certname}.pem",
    require => Puppet_certificate[$certname],
    notify  => Service['pe-puppetdb'],
  }

  ini_setting { 'puppetdb-jetty-ssl_key':
    path    => $puppetdb_jettyini,
    section => 'jetty',
    setting => 'ssl-key',
    value   => $puppetdb_sslkey,
    require => File[$puppetdb_sslkey],
    notify  => Service['pe-puppetdb'],
  }
  ini_setting { 'puppetdb-jetty-ssl_cert':
    path    => $puppetdb_jettyini,
    section => 'jetty',
    setting => 'ssl-cert',
    value   => $puppetdb_sslcert,
    require => File[$puppetdb_sslcert],
    notify  => Service['pe-puppetdb'],
  }
  ini_setting { 'puppetdb-jetty-ssl_ca_cert':
    path    => $puppetdb_jettyini,
    section => 'jetty',
    setting => 'ssl-ca-cert',
    value   => "/etc/puppetlabs/puppet/ssl/certs/ca.pem",
    notify  => Service['pe-puppetdb'],
  }

}
