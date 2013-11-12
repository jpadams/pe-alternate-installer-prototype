class pe_memcached (
  $version = installed,
) {

  package { 'pe-memcached':
    ensure => $version,
  }
  
  service { 'pe-memcached':
    ensure  => running,
    enable  => true,
    require => Package['pe-memcached'],
  }

}
