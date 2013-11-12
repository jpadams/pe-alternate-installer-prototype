define pe_httpd::conf (
  $template         = undef,
  $template_options = undef,
  $content          = undef,
  $source           = undef,
  $ensure           = present,
  $vdir             = '/etc/puppetlabs/httpd/conf.d',
) {
  include pe_httpd

  if ($template and $content) {
    fail('can only supply one of either content or template parameter')
  } elsif $content {
    $use_content = $content
  } elsif $template {
    $use_content = template($template)
  } else {
    $use_content = undef
  }

  if $source {
    $use_source = $source
  } else {
    $use_source = undef
  }

  # Potentially uses $template_options variable
  file { "${vdir}/${name}":
    ensure   => $ensure,
    owner    => '0',
    group    => '0',
    mode     => '0644',
    content  => $use_content,
    source   => $use_source,
    notify   => Service['pe-httpd'],
  }

}
