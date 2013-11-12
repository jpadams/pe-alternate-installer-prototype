#
# This class inherits from pe_role in order to use parameters set there.
#
class pe_role::puppetagent (
  $master_host = $pe_role::puppetmaster,
  $master_port = '8140',
  $ca_host     = $pe_role::puppetca,
  $ca_port     = '8140',
  $certname    = $::clientcert,
  $config_file = '/etc/puppetlabs/puppet/puppet.conf',
) inherits pe_role {

  class { 'pe_puppet::agent':
    master_host => $master_host,
    master_port => $master_port,
    ca_host     => $ca_host,
    ca_port     => $ca_port,
    certname    => $certname,
    config_file => $config_file,
  }

}
