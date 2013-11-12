# == Class: pe_role::puppetmaster
#
# The pe_role::puppetmaster class is a top-level role classifier that
# leverages default values set in pe_role and functionality provided by the
# pe_puppet and pe_httpd modules to set up the Puppet master service.
#
# === Parameters
#
# [*ca_host*]
#   The resolvable name to use to reach the Puppet certificate authority
#   service.
#
# [*ca_port*]
#   The port to use to connect to the Puppet certificate authority service.
#
# [*certname*]
#   The certificate name to use for the Puppet master service. This
#   certificate will be created if it does not exist on the system, and is used
#   to authenticate communication with the Puppet agent system(s).
#
# [*dns_alt_names*]
#   The full list of resolvable names that may be used to connect to the
#   Puppet master service. These names will become subjectAlternativeName(s)
#   in the generated certificate for the Puppet master service.
#
# [*confdir*]
#   The Puppet confdir. See the configuration reference for a reference on
#   the confdir setting.
#
# [*config_file*]
#   The location of the puppet.conf file.
#
# [*console_host*]
#   The resolvable name to use to reach the Puppet Console service. This is
#   primarily used to tell the Puppet master service where to send reports via
#   the https report processor.
#
# [*console_port*]
#   The port to use to connect to the Puppet console service when sending
#   reports.
#
# [*inventory_dbname*]
#   The name of the database used for Active Record storeconfigs. This option
#   is not used when either a) storeconfigs are not being used, or b) PuppetDB
#   is being used.
#
# [*inventory_dbpassword*]
#   The database password used for Active Record storeconfigs. This option is
#   not used when either a) storeconfigs are not being used, or b) PuppetDB is
#   being used.
#
# [*inventory_dbhost*]
#   The resolvable name used to reach the Active Record storeconfigs database
#   service. This option is not used when either a) storeconfigs are not being
#   used, or b) PuppetDB is being used.
#
# [*inventory_dbuser*]
#   The database username used for Active Record storeconfigs. This option is
#   not used when either a) storeconfigs are not being used, or b) PuppetDB is
#   being used.
#
# [*modulepath*]
#   The modulepath to use for the Puppet master service. See the configuration
#   reference for more information about the modulepath setting.
#
# [*puppetdb_host*]
#   The resolvable name used to reach the PuppetDB service, if PuppetDB is to
#   be used.
#
# [*puppetdb_port*]
#   The port to use to connect to the PuppetDB service, if PuppetDB is to be
#   used.
#
class pe_role::puppetmaster (
  $ca_host                    = $pe_role::puppetca,
  $ca_port                    = '8140',
  $certname                   = "${pe_role::puppetmaster_cert_prefix}.${::clientcert}",
  $dns_alt_names              = "${::clientcert},${::hostname},puppet,puppet.${::domain}",
  $confdir                    = '/etc/puppetlabs/puppet',
  $config_file                = '/etc/puppetlabs/puppet/puppet.conf',
  $console_host               = $pe_role::puppetconsole,
  $console_port               = '443',
  $inventory_dbname           = 'console_inventory_service',
  $inventory_dbpassword       = undef,
  $inventory_dbhost           = undef,
  $inventory_dbuser           = 'console',
  $modulepath                 = '/etc/puppetlabs/puppet/modules:/opt/puppet/share/puppet/modules',
  $manifest                   = undef,
  $puppetdb_host              = $pe_role::puppetdb,
  $puppetdb_port              = '8081',
  $puppetdb_strict_validation = false,
) inherits pe_role {

  include pe_role::agent

  class { 'pe_puppet::master':
    require                    => Anchor['pe_role::setup_database'],
    ca_host                    => $ca_host,
    ca_port                    => $ca_port,
    certname                   => $certname,
    confdir                    => $confdir,
    config_file                => $config_file,
    console_host               => $console_host,
    console_port               => $console_port,
    inventory_dbname           => $inventory_dbname,
    inventory_dbpassword       => $inventory_dbpassword,
    inventory_dbhost           => $inventory_dbhost,
    inventory_dbuser           => $inventory_dbuser,
    modulepath                 => $modulepath,
    manifest                   => $manifest,
    puppetdb_host              => $puppetdb_host,
    puppetdb_port              => $puppetdb_port,
    puppetdb_strict_validation => $puppetdb_strict_validation,
  }

  include puppet_auth::defaults
  include puppet_auth::purge

  puppet_auth { 'Auth rule for /resource_type (find, search)':
    ensure        => present,
    methods       => ['find', 'search'],
    authenticated => 'yes',
  }
  puppet_auth_allow { "/resource_type: allow /^${pe_role::puppetconsole_cert_prefix}\\.?.*\$/":
    ensure  => present,
    path    => '/resource_type',
    allow   => "/^${pe_role::puppetconsole_cert_prefix}\\.?.*\$/",
    require => Puppet_auth['Auth rule for /resource_type (find, search)'],
  }

  puppet_auth { 'Auth rule for /facts (find, search)':
    ensure        => present,
    methods       => ['find', 'search'],
    authenticated => 'any',
    priority      => '70',
  }
  puppet_auth_allow { "/facts: allow /^${pe_role::puppetconsole_cert_prefix}\\.?.*\$/":
    ensure  => present,
    path    => '/facts',
    allow   => "/^${pe_role::puppetconsole_cert_prefix}\\.?.*\$/",
    require => Puppet_auth['Auth rule for /facts (find, search)'],
  }

  # Export a whitelist entry for PuppetDB
  @@pe_role::util::puppetdb_whitelist { "export from ${certname}":
    ensure  => present,
    line    => $certname,
  }

}
