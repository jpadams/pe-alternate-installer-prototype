define puppet_dashboard::class (
  $ensure = present,
) {

  Exec {
    cwd  => '/opt/puppet/share/puppet-dashboard',
    path => '/opt/puppet/bin:/usr/bin:/bin',
  }

  $opts = "RAILS_ENV=production"

  case $ensure {
    present: {
      exec { "puppet_dashboard_class_create_${title}":
        command => "rake nodeclass:add name=${name} ${opts}",
        unless  => "rake nodeclass:list ${opts} | grep -e '^${name}\$'",
      }
    }
    absent: {
      exec { "puppet_dashboard_class_destroy_${title}":
        command => "rake nodeclass:del name=${name} ${opts}",
        onlyif  => "rake nodeclass:list ${opts} | grep -e '^${name}\$'",
      }
    }
    default: {
      fail("ensure must be the keyword present or the keyword absent")
    }
  }

}
