class pe_mcollective::client::puppet_dashboard (
  $mcollective_enable_stomp_ssl  = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_password                = $pe_mcollective::params::stomp_password,
  $stomp_port                    = $pe_mcollective::params::stomp_port,
  $stomp_servers                 = $pe_mcollective::params::stomp_servers,
  $stomp_user                    = $pe_mcollective::params::stomp_user,
) inherits pe_mcollective::params {
  include pe_mcollective::client

  $logfile           = '/var/log/pe-puppet-dashboard/mcollective_client.log'
  $pd_home           = '/opt/puppet/share/puppet-dashboard'
  $private_key_path  = "$pd_home/.mcollective.d/puppet-dashboard-private.pem"
  $public_key_path   = "$pd_home/.mcollective.d/puppet-dashboard-public.pem"
  $cert_path         = "$pd_home/.mcollective.d/puppet-dashboard-cert.pem"
  $cacert_path       = "$pd_home/.mcollective.d/puppet-dashboard-cacert.pem"
  $server_public_key_path  = "$pd_home/.mcollective.d/mcollective-public.pem"

  # Master+console nodes use source with a local file path for the content.
  # Console-only nodes use content with a file function to deliver in-band.
  # Our basic premise is that master node is available before the console
  # install is run.
  include pe_mcollective::shared_key_files
  File <| tag == 'pe_mco_client_puppet_dashboard' |>

  # (#9694) - Manage the encryption keys for the puppet-dashboard user
  pe_accounts::user { 'puppet-dashboard':
    ensure   => present,
    password => '!!',
    home     => "$pd_home",
    before   => [
      File['/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-private.pem'],
      File['/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-public.pem'],
      File['/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cert.pem'],
      File['/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cacert.pem'],
    ],
  }
  # The home directory must be world-readable for the Dashboard to work
  # in Apache. This resource is declared in the accounts::user defined
  # type.
  File <| title == "$pd_home" |> {
    mode => '0755',
  }
  # Manage the path correctly
  # Template uses: $puppetversion (fact)
  file { "$pd_home/.bashrc.custom":
    ensure  => file,
    content => template("${module_name}/bashrc_custom.erb"),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0600',
    require => Pe_accounts::User['puppet-dashboard'],
  }
  # Template uses:
  # - $puppetversion (fact)
  # - $mcollective_enable_stomp_ssl
  # - $private_cert_path
  # - $public_cert_path
  # - $stomp_user
  # - $stomp_password
  # - $stomp_servers
  # - $stomp_port
  # - $logfile
  # - $public_key_path
  # - $private_key_path
  # - $cert_path
  # - $cacert_path
  # - $server_public_key_path
  file { "$pd_home/.mcollective":
    ensure  => file,
    content => template('pe_mcollective/client.cfg.erb'),
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0600',
    require => Pe_accounts::User['puppet-dashboard'],
  }
  file { "$pd_home/.mcollective.d":
    ensure  => directory,
    owner   => 'puppet-dashboard',
    group   => 'puppet-dashboard',
    mode    => '0700',
    require => Pe_accounts::User['puppet-dashboard'],
  }

}
