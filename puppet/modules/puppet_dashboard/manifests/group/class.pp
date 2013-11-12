define puppet_dashboard::group::class (
  $group    = regsubst($title, '###.*', ''),
  $addclass = regsubst($title, '^.*###', ''),
) {

  $opts = "name='${group}' RAILS_ENV=production"

  exec { "puppet_dashboard_group_class_create_${title}":
    command => "rake nodegroup:addclass class='${addclass}' ${opts}",
    unless  => "rake nodegroup:listclasses ${opts} | grep -e '^${addclass}\$'",
  }

}
