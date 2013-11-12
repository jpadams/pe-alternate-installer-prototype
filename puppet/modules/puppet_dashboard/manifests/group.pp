define puppet_dashboard::group (
  $ensure      = present,
  $classes     = [],
  $init_params = [],
) {

  Exec {
    cwd  => '/opt/puppet/share/puppet-dashboard',
    path => '/opt/puppet/bin:/usr/bin:/bin',
  }

  $opts = "RAILS_ENV=production"

  case $ensure {
    present: {
      exec { "puppet_dashboard_group_create_${title}":
        command => "rake nodegroup:add name='${name}' ${opts}",
        unless  => "rake nodegroup:list ${opts} | grep -e '^${name}\$'",
        notify  => Exec["puppet_dashboard_group_init_params_${title}"],
      }

      # Note that init_params will only be applied when the group is first
      # created. They will not be continuously enforced.
      $init_params_joined = join($init_params, ',')
      $init_params_opts   = "name='${name}' parameters=${init_params_joined}"
      exec { "puppet_dashboard_group_init_params_${title}":
        command     => "rake nodegroup:parameters ${init_params_opts} ${opts}",
        refreshonly => true,
      }

      $classes_with_group_prefix = prefix([$classes], "${name}###")
      puppet_dashboard::group::class { $classes_with_group_prefix:
        require => Exec["puppet_dashboard_group_create_${title}"],
      }

    }
    absent: {
      exec { "puppet_dashboard_group_destroy_${title}":
        command => "rake nodegroup:del name='${name}' ${opts}",
        onlyif  => "rake nodegroup:list ${opts} | grep -e '^${name}\$'",
      }
    }
    default: {
      fail("ensure must be the keyword present or the keyword absent")
    }
  }


}
