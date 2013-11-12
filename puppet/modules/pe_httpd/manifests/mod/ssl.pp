class pe_httpd::mod::ssl {
  include pe_httpd

  file { "${pe_httpd::confdir}/conf.d/headers.conf":
    ensure  => file,
    owner   => '0',
    group   => '0',
    mode    => '0644',
    content => "RequestHeader unset X-Forwarded-For\n",
    notify  => Service['pe-httpd'],
    require => Package['pe-httpd'],
  } 

  case $::osfamily {
    'Debian': {
      Exec {
        notify  => Service['pe-httpd'],
        require => Package['pe-httpd'],
      }
      exec { '/opt/puppet/sbin/a2enmod ssl':
        creates => "${pe_httpd::confdir}/mods-enabled/ssl.load",
      }
      exec { '/opt/puppet/sbin/a2enmod headers':
        creates => "${pe_httpd::confdir}/mods-enabled/headers.load",
      }
      exec { '/opt/puppet/sbin/a2enmod authnz_ldap':
        creates => "${pe_httpd::confdir}/mods-enabled/authnz_ldap.load",
      }
      exec { '/opt/puppet/sbin/a2enmod ldap':
        creates => "${pe_httpd::confdir}/mods-enabled/ldap.load",
      }
    }
    'RedHat': {
      package { 'pe-mod_ssl':
        ensure => installed,
        notify => Service['pe-httpd'],
      }
    }
  }

}
