define pe_role::util::puppetdb_whitelist (
  $ensure = present,
  $line   = $title,
) {

  # We have a potential conflict between entries coming in from the default
  # whitelist, and entries coming in from exported resources. This allows
  # peaceful coexistence.
  if ! defined(File_line["puppetdb_whitelist:${line}"]) {
    file_line { "puppetdb_whitelist:${line}":
      path    => '/etc/puppetlabs/puppetdb/certificate-whitelist',
      line    => $line,
      notify  => Service['pe-puppetdb'],
      require => File['/etc/puppetlabs/puppetdb/certificate-whitelist'],
    }
  }

}
