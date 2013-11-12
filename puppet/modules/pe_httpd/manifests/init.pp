## PuppetDB and Console/Dashboard both have needs of the pe-httpd service
## PuppetDB => subscribe => puppet.conf
## console/dashboard  => subscribe => auth.conf

# leverage puppetlabs/apache if possible
class pe_httpd (
  $httpd_version     = installed,
  $passenger_version = installed,
  $rack_version      = installed,
  $confdir           = '/etc/puppetlabs/httpd',
) {
  include pe_memcached
  include pe_httpd::mod::ssl

  package { 'pe-httpd':
    ensure => $httpd_version,
    before => Service['pe-httpd'],
  }

  package { 'pe-passenger':
    ensure => $passenger_version,
    before => Service['pe-httpd'],
  }

  package { 'pe-rubygem-rack':
    ensure => $rack_version,
    before => Service['pe-httpd'],
  }

  service { 'pe-httpd':
    ensure  => running,
    enable  => true,
    require => Service['pe-memcached'],
  }

  file { "${confdir}/conf.d":
    ensure  => directory,
    owner   => '0',
    group   => '0',
    mode    => '0755',
    notify  => Service['pe-httpd'],
    require => Package['pe-httpd'],
  }

}
