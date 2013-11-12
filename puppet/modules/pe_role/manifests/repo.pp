class pe_role::repo {
  include pe_role
  include pe_httpd

  class { 'pe_repo':
    puppet_master  => $pe_role::puppetmaster,
    linux_repos    => 'el-6-x86_64',
    package_mirror => $pe_role::puppetmaster,
  }

}
