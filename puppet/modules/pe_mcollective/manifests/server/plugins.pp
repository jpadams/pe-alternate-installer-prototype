# Class: pe_mcollective::plugins
#
# This class manages the security plugin for MCollective in Puppet Enterprise.
#
# This class is meant to be declared from the main pe_mcollective class and
# should not be declared directly by the end user of Puppet Enterprise.
#
# In addition, the class also deploys all of the supported MCollective plugins shipped
# as part of Puppet Enterprise.
#
class pe_mcollective::server::plugins {
  # API WARNING: PE docs rely on the $plugin_basedir variable. They also expect
  # that if any subdirectories of the $plugin_basedir directory are to be
  # managed as resources, they will be managed in THIS class rather than a
  # user-created class. See:
  # http://docs.puppetlabs.com/pe/latest/orchestration_adding_actions.html
  $plugin_basedir = $::osfamily ? {
    'windows' => "${pe_mcollective::params::mco_etc}/plugins/mcollective",
    default   => '/opt/puppet/libexec/mcollective/mcollective'
  }

  File {
    owner  => $pe_mcollective::params::root_owner,
    group  => $pe_mcollective::params::root_group,
    mode   => $pe_mcollective::params::root_mode,
    notify => Service['pe-mcollective']
  }

  # REMIND: it seems very fragile for this module to assume that the installer,
  # *nix or otherwise, has created the necessary parent directories. Is there
  # any reason to not create the `plugins` and `plugins/mcollective` directories
  # on all platforms?
  if $::osfamily == 'windows' {
    file { "${pe_mcollective::params::mco_etc}/plugins": ensure => directory }
  }

  file { "${plugin_basedir}":
    ensure => directory,
    recurse => remote,
    source => "puppet:///modules/${module_name}/plugins",
  }

  file { "${plugin_basedir}/agent/puppetd.rb": ensure => absent }

  file { "${plugin_basedir}/agent/puppetd.ddl": ensure => absent }

  file { "${plugin_basedir}/application/puppetd.rb": ensure => absent }
}
