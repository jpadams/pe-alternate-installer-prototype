# == Class: pe_role::agent
#
# The pe_role::agent class is a convenience wrapper for the pe_role::puppetagent
# and pe_role::mcoserver classes. It cannot be used to pass in parameters and
# expects any customization data to come from hiera. If specification of
# custom parameters is required in the absence of hiera, pe_role::puppetagent
# and pe_role::mcoserver should be declared independently and pe_role::agent
# not used.
#
# === Examples
#
#  include pe_role::agent
#
# === Authors
#
# Puppet Labs
#
# Original author:
#   Reid Vandewiele <reid@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Puppet Labs, unless otherwise noted
#
class pe_role::agent {

  include pe_role::puppetagent
  include pe_role::mcoserver

}
