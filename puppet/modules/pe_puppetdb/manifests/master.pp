# == Class: pe_puppetdb::master
#
# This class configures puppet master once puppetdb is available.
#
# If puppetdb is not available yet then only a notice is generated.
#
# === Parameters:
#
# none
#
# === Example:
#
# class { 'pe_puppetdb::master':
# }
#
class pe_puppetdb::master(
  $puppetdb_server         = undef,
  $puppetdb_port           = undef,
  $manage_config           = false,
  $manage_storeconfigs     = true,
  $manage_routes           = true,
  $manage_report_processor = true,
  $enable_reports          = true,
  $puppet_confdir          = '/etc/puppetlabs/puppet',
  $strict_validation       = false,
) {

  class { 'puppetdb::master::config':
    puppetdb_server         => $puppetdb_server,
    puppetdb_port           => $puppetdb_port,
    manage_config           => $manage_config,
    manage_storeconfigs     => $manage_storeconfigs,
    manage_routes           => $manage_routes,
    manage_report_processor => $manage_report_processor,
    enable_reports          => $enable_reports,
    puppet_confdir          => $puppet_confdir,
    strict_validation       => $strict_validation,
  }

}
