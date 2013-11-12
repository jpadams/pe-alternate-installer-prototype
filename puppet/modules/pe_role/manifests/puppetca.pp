class pe_role::puppetca {

  include pe_role
  include pe_role::agent
  include pe_role::puppetmaster
  include pe_puppet::ca

  include pe_mcollective::role::ca

  puppet_auth { 'Auth rule for /certificate_status (find, search, save, destroy)':
    ensure        => 'present',
    methods       => ['find', 'search', 'save', 'destroy'],
    authenticated => 'yes',
    priority      => '70',
  }
  puppet_auth_allow { "/certificate_status: allow /^${pe_role::puppetconsole_cert_prefix}\\.?.*\$/":
    ensure  => present,
    path    => '/certificate_status',
    allow   => "/^${pe_role::puppetconsole_cert_prefix}\\.?.*\$/",
    require => Puppet_auth['Auth rule for /certificate_status (find, search, save, destroy)'],
  }

}
