class pe_console::certificate_manager (
  $certificatemanager_version = installed,
) {

  package { 'pe-certificate-manager':
    ensure => $certificatemanager_version,
  }

  file { '/var/log/pe-puppet-dashboard/certificate_manager.log':
    ensure => file,
    owner  => 'puppet-dashboard',
    group  => 'puppet-dashboard',
    mode   => '0644',
    notify => Service['pe-puppet-dashboard-workers'],
  }

}
