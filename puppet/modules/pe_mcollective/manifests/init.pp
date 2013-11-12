# MCollective Puppet Enterprise
#
# This module manages the initial configuration of MCollective for use with
# Puppet Enterprise.  The primary purpose is to generate RSA key pairs for the
# initial "peadmin" user account on the Puppet Master and a shared set of RSA keys
# for all of the MCollective server processes (Puppet Agent roles).
#
# Resources managed on a Puppet Master:
#
#  * peadmin user account
#  * RSA keys to identify and authorize the peadmin user.
#  * One set of RSA keys generated for shared use among all MCollective agents.
#
# Resources managed on a Puppet Agent:
#
#  * RSA keys for MCollective service
#  * peadmin user account public RSA key to authenticate the peadmin user
#
# == Parameters
#
# This class expects four facts to be provided:
#
#  * fact_stomp_server    (hostname)
#  * fact_stomp_port      (TCP port number)
#  * is_pe
#  * pe_major_version
#
# The facts are automatically set by the Puppet Enterprise installer for each
# system.
#
# If a pre-shared-key is used, a randomly generated string (The contents of the
# mcollective credientials file) with be fed into the SHA1 hash algorithm to
# produce a unique key.
#
# T# (#9045) Update facter facts on disk periodically using a cron jobhis module will automatically setup up openwire network connectors for all
# brokers you indicate.  To do this you can either set an array using the
# parameters or from within the Console set activemq_brokers to a comma
# seperated list and the module with do the correct thing.
#
class pe_mcollective (
  $warn_on_nonpe_agents   = true,
  $warn_on_nonpe3_agents  = true,
) {
  include pe_mcollective::params

  # API WARNING: PE docs rely on the fact that declaring this class will
  # eventually cause the pe_mcollective::params class and the
  # pe_mcollective::server::plugins class to be declared; examples use include
  # on this class and variables from both of those classes. See:
  # http://docs.puppetlabs.com/pe/latest/orchestration_adding_actions.html
    class { 'pe_mcollective::role::agent':
      warn_on_nonpe_agents   => $warn_on_nonpe_agents,
      warn_on_nonpe3_agents  => $warn_on_nonpe3_agents,
    }

}
