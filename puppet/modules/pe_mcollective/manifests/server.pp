class pe_mcollective::server (
  $mcollective_enable_stomp_ssl  = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_password                = $pe_mcollective::params::stomp_password,
  $stomp_port                    = $pe_mcollective::params::stomp_port,
  $stomp_servers                 = $pe_mcollective::params::stomp_servers,
  $stomp_user                    = $pe_mcollective::params::stomp_user,
  $mcollective_registerinterval  = $pe_mcollective::params::mcollective_registerinterval,
) inherits pe_mcollective::params {
  include pe_mcollective::server::plugins

  include pe_mcollective::shared_key_files
  File <| tag == 'pe_mco_server' |>

  if !($::osfamily == 'windows') {
    File {
      require => Package['pe-mcollective'],
    }
    package { 'pe-mcollective':
      ensure => present,
      before => Service['pe-mcollective'],
    }
  }

  $private_key_path = "${mco_etc}/ssl/mcollective-private.pem"
  $public_key_path  = "${mco_etc}/ssl/mcollective-public.pem"
  $cert_path        = "${mco_etc}/ssl/mcollective-cert.pem"
  $cacert_path      = "${mco_etc}/ssl/mcollective-cacert.pem"
  $client_cert_dir  = "${mco_etc}/ssl/clients/"

  $plugin_libdir = $::operatingsystem ? {
    'windows' => "${mco_etc}/plugins;${env_windows_installdir}/mcollective_plugins",
    default   => '/opt/puppet/libexec/mcollective/'
  }

  $server_logfile = $::operatingsystem ? {
    'windows' => "${common_appdata}/PuppetLabs/mcollective/var/log/mcollective.log",
    'AIX'     => '/opt/freeware/var/log/pe-mcollective/mcollective.log',
    default   => '/var/log/pe-mcollective/mcollective.log'
  }

  #Switching back to using exec from file line.  logadm adds a timestamp to the command when it runs.  This caused the line to be modified on every puppet run.
  if $::operatingsystem == 'solaris' {
    exec { "Solaris: pe-mcollective log rotation":
      command => "/usr/bin/echo '# pe-mcollective log rotation rule\n/var/log/pe-mcollective/mcollective.log -C 14 -c -p 1w' >> /etc/logadm.conf",
      unless  => "/usr/bin/grep 'pe-mcollective/mcollective.log' /etc/logadm.conf > /dev/null",
    }
  }

  # Don't accept the shared server public key as a client, or every server can
  # act as a client!
  file { "${mco_etc}/ssl/clients/mcollective-public.pem":
    ensure => absent,
  }

  # Manage the MCollective server configuration
  # Template uses:
  # - $puppetversion (fact)
  # - $operatingsystem (fact)
  # - $clientcert (top-scope variable)
  # - $mcollective_enable_stomp_ssl
  # - $stomp_user
  # - $stomp_password
  # - $stomp_servers
  # - $stomp_port
  # - $public_key_path
  # - $private_key_path
  # - $cert_path
  # - $cacert_path
  # - $client_cert_dir
  # - $plugin_libdir
  # - $server_logfile
  # - $mco_etc
  # - $env_windows_installdir (fact, windows-only)
  # - $mcollective_registerinterval
  file { "${mco_etc}/server.cfg":
    content => template("${module_name}/server.cfg.erb"),
    mode    => '0600',
    notify  => Service['pe-mcollective'],
  }
  service { 'pe-mcollective':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
  # API WARNING: PE docs rely on this service being named 'pe-mcollective'. See:
  # http://docs.puppetlabs.com/pe/latest/orchestration_adding_actions.html

  # Manage facter metadata updates for MCollective in PE.
  if $::osfamily == 'windows' {
    file { 'refresh-mcollective-metadata.bat':
      path    => "${mco_etc}/refresh-mcollective-metadata.bat",
      owner   => "${pe_mcollective::params::root_owner}",
      group   => "${pe_mcollective::params::root_group}",
      mode    => '0775',
      content => template('pe_mcollective/refresh-mcollective-metadata.bat.erb'),
      before  => [ Exec['bootstrap mcollective metadata'], Scheduled_task['pe-mcollective-metadata'] ],
    }
    exec { 'bootstrap mcollective metadata':
      command => "\"${mco_etc}/refresh-mcollective-metadata.bat\"",
      creates => "${mco_etc}/facts.yaml",
      before  => Service['pe-mcollective'],
    }
    scheduled_task { 'pe-mcollective-metadata':
      ensure  => 'present',
      command => "${mco_etc}/refresh-mcollective-metadata.bat",
      enabled => 'true',
      trigger => { 'every' => '1', 'schedule' => 'daily', 'start_time' => '13:00' },
    }
  } else {
    file { '/opt/puppet/sbin/refresh-mcollective-metadata':
      owner   => '0',
      group   => '0',
      mode    => '0755',
      content => template('pe_mcollective/refresh-mcollective-metadata'),
      before  => Cron['pe-mcollective-metadata'],
    }
    cron { 'pe-mcollective-metadata':
      command => '/opt/puppet/sbin/refresh-mcollective-metadata',
      user    => 'root',
      minute  => [ '0', '15', '30', '45' ],
    }
  }
}
