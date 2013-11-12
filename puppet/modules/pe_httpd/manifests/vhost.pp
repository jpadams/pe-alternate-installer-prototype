define pe_httpd::vhost (
  $template         = undef,
  $template_options = undef,
  $content          = undef,
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
    fail('must supply one of either content or template parameter')
  }

  # Potentially uses $template_options variable
  file { "${vdir}/${name}.conf":
    ensure   => $ensure,
    owner    => '0',
    group    => '0',
    mode     => '0644',
    content  => $use_content,
    notify   => Service['pe-httpd'],
  }

}
