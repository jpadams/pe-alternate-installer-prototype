define pe_mcollective::puppet_certificate (
  $certname      = $title,
  $ssldir        = $::settings::ssldir,
  $dns_alt_names = undef
) {

  # Depending on whether the CA is local or remote, choose whether to sign
  # the new cert or just try to request it from the remote CA when it's time
  # to "get" the certificate.
  $key_file        = "$ssldir/private_keys/$certname.pem"
  $cert_file       = "$ssldir/certs/$certname.pem"
  $alt_name_options = $dns_alt_names ? {
    undef   => "",
    default => "--dns_alt_names $dns_alt_names",
  }

  exec { "generate_cert_for_$title":
    command => "puppet cert generate $certname $alt_name_options",
    unless  => "test -s $cert_file -o -s $key_file",
    logoutput => on_failure,
    path      => '/opt/puppet/bin:/usr/bin:/bin:/usr/sbin:/sbin',
  }
}
