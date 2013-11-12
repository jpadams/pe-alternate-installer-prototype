define pe_console::rake_task (
  $task,
  $unless_task = undef,
  $onlyif_task = undef,
  $rakefile    = '/opt/puppet/share/puppet-dashboard/Rakefile',
  $cwd         = '/opt/puppet/share/puppet-dashboard',
  $creates     = undef,
  $refreshonly = undef,
) {

  $unless = $unless_task ? {
    undef   => undef,
    default => "bundle exec rake -f ${rakefile} ${unless_task}",
  }

  $onlyif = $onlyif_task ? {
    undef   => undef,
    default => "bundle exec rake -f ${rakefile} ${onlyif_task}",
  }

  exec { "pe_console_rake_task_${title}":
    path        => '/opt/puppet/bin:/usr/bin:/bin',
    cwd         => $cwd,
    command     => "bundle exec rake -f ${rakefile} ${task}",
    refreshonly => $refreshonly,
    creates     => $creates,
    unless      => $unless,
    onlyif      => $onlyif,
  }

}
