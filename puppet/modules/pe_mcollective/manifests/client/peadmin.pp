class pe_mcollective::client::peadmin (
  $mcollective_enable_stomp_ssl  = $pe_mcollective::params::mcollective_enable_stomp_ssl,
  $stomp_password                = $pe_mcollective::params::stomp_password,
  $stomp_port                    = $pe_mcollective::params::stomp_port,
  $stomp_servers                 = $pe_mcollective::params::stomp_servers,
  $stomp_user                    = $pe_mcollective::params::stomp_user,
) inherits pe_mcollective::params {
  include pe_mcollective::client

  $peadmin_home     = '/var/lib/peadmin'
  $logfile          = "$peadmin_home/.mcollective.d/client.log"
  $private_key_path = "$peadmin_home/.mcollective.d/peadmin-private.pem"
  $public_key_path  = "$peadmin_home/.mcollective.d/peadmin-public.pem"
  $cert_path        = "$peadmin_home/.mcollective.d/peadmin-cert.pem"
  $cacert_path      = "$peadmin_home/.mcollective.d/peadmin-cacert.pem"
  $server_public_key_path  = "$peadmin_home/.mcollective.d/mcollective-public.pem"

  # Master+console nodes use source with a local file path for the content.
  # Console-only nodes use content with a file function to deliver in-band.
  # Our basic premise is that master node is available before the console
  # install is run.
  include pe_mcollective::shared_key_files
  File <| tag == 'pe_mco_client_peadmin' |>

  pe_accounts::user { 'peadmin':
    ensure   => present,
    password => '!!',
    home     => $peadmin_home,
    before   => [
      File['/var/lib/peadmin/.mcollective.d/peadmin-private.pem'],
      File['/var/lib/peadmin/.mcollective.d/peadmin-public.pem'],
      File['/var/lib/peadmin/.mcollective.d/peadmin-cert.pem'],
      File['/var/lib/peadmin/.mcollective.d/peadmin-cacert.pem'],
    ],
  }
  # Template uses:
  # - $puppetversion (fact)
  # - $mcollective_enable_stomp_ssl
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
  file { "$peadmin_home/.mcollective":
    content => template('pe_mcollective/client.cfg.erb'),
    require => Pe_accounts::User['peadmin'],
  }
  file { '/etc/puppetlabs/mcollective/client.cfg':
    ensure  => absent,
  }
  file { "$peadmin_home/.mcollective.d":
    ensure  => directory,
    mode    => '0700',
    require => Pe_accounts::User['peadmin'],
  }

  # Because the accounts module is managing the .bashrc, we use
  # .bashrc.custom, which is included by default in the managed .bashrc
  # Template uses: $puppetversion (fact)
  file { "$peadmin_home/.bashrc.custom":
    ensure  => file,
    content => template("${module_name}/bashrc_custom.erb"),
    mode    => '0644',
    require => Pe_accounts::User['peadmin'],
  }
}
