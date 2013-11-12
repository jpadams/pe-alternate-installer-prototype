# == Class: pe_repo
#
# Full description of class pe_repo here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { pe_repo:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class pe_repo (
  $puppet_master = $::fqdn,
  $linux_repos = [
    'el-6-x86_64',
    'debian-7-amd64',
  ],
  $package_mirror = $::fqdn,
  $enable_linux = true,
  $enable_windows = false,
  $enable_solaris = false,
  $enable_aix = false,
  $repo_port = 80,
  $pe_version = $::pe_version,
  $install_httpd = false,
){

  File {
    ensure => file,
    mode   => 644,
    owner  => root,
    group  => root,
  }

  #build file structure
  file { '/opt/puppet/pe_repo': ensure => directory, }
  file { '/opt/puppet/pe_repo/html': ensure => directory, }

  #our welcome page
  file { '/opt/puppet/pe_repo/html/index.html':
    content => template('pe_repo/index.erb'),
  }
  # our curl pipe bash scripts
  file { '/opt/puppet/pe_repo/html/deb.bash':
    content => template('pe_repo/deb.bash.erb'),
  }
  file { '/opt/puppet/pe_repo/html/el.bash':
    content => template('pe_repo/el.bash.erb'),
  }
  # our puppet.conf file
  file { '/opt/puppet/pe_repo/html/puppet.conf':
    content => template('pe_repo/puppet.conf.erb'),
  }
  # our yum repo
  file { '/opt/puppet/pe_repo/html/el.repo':
    content => template('pe_repo/elrepo.erb'),
  }
  # needed support files
  file { '/opt/puppet/pe_repo/html/pe_version':
    content => $pe_version,
  }
  file { '/opt/puppet/pe_repo/html/GPG-KEY-puppetlabs':
    source => 'puppet:///modules/pe_repo/GPG-KEY-puppetlabs',
  }

  # if we want, we can install pe-httpd on a non master system
  if $install_httpd == true {
    package { 'pe-httpd':
      ensure => installed,
      before => File['/etc/puppetlabs/httpd/conf.d/pe_repo.conf'],
    }
  }

  # enable port and sharing the repo
  file { '/etc/puppetlabs/httpd/conf.d/pe_repo.conf':
    content => template('pe_repo/pe_repo.conf.erb'),
    notify  => Service['pe-httpd'],
  }

  # This builds the repos, call with pe_repo with enable_linux=false if you want tuneable locations
  if $enable_linux == true {
    pe_repo::repo {$linux_repos:}
  }

  #here is our non repo friendly distros
  if $enable_windows == true {
    exec { 'download_windows':
      command => "/usr/bin/curl -O http://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}.msi",
      cwd     => '/opt/pe_repo/html/',
      creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}.msi",
      require => File['/opt/pe_repo/html'],
    }
  }
  if $enable_solaris == true {
    file { '/opt/pe_repo/html/solaris.bash':
      content => template('pe_repo/solaris.bash.erb'),
    }
    exec { 'download_solaris_sparc':
      command => "/usr/bin/curl -O http://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}-solaris-10-sparc.tar.gz",
      cwd     => '/opt/pe_repo/html/',
      creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}-solaris-10-sparc.tar.gz",
      require => File['/opt/pe_repo/html'],
    }
    exec { 'download_solaris_i386':
      command => "/usr/bin/curl -O http://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}-solaris-10-i386.tar.gz",
      cwd     => '/opt/pe_repo/html/',
      creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}-solaris-10-i386.tar.gz",
      require => File['/opt/pe_repo/html'],
    }
  }
  if $enable_aix == true {
    exec { 'download_aix5':
      command => "/usr/bin/curl -O http://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}.msi",
      cwd     => '/opt/pe_repo/html/',
      creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}.msi",
      require => File['/opt/pe_repo/html'],
    }
    exec { 'download_aix6':
      command => "/usr/bin/curl -O http://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}.msi",
      cwd     => '/opt/pe_repo/html/',
      creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}.msi",
      require => File['/opt/pe_repo/html'],
    }
    exec { 'download_aix7':
      command => "/usr/bin/curl -O http://s3.amazonaws.com/pe-builds/released/${pe_version}/puppet-enterprise-${pe_version}.msi",
      cwd     => '/opt/pe_repo/html/',
      creates => "/opt/pe_repo/html/puppet-enterprise-${pe_version}.msi",
      require => File['/opt/pe_repo/html'],
    }
  }
}
