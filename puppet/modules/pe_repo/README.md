pe_repo

This is the pe_repo module.

This is meant to help you create a repo of PE packages on a console/master of your choice, making it easy to deploy agents via packages exclusively.

It works by mirroring using the staging module to copy and unpack the build specific versions of the pe installer, and reshares that build's packages folders using Puppetlab's vendored pe-http module (by default, available on any PE master or Console server, and available to install on any agent that has been previously installed with this module).

It then generates a site specific series of commands you can use to:
Add the repository for that distribution to the os's package provider
List of packages to be installed (hopefully soon replaced with pe-agent metapackage)
Example puppet.conf file that this module will also generate for you
How to start the service

If you want, these commands can be piped into /bin/bash directly to execute the installation steps, however this is running arbitrary shell code you downloaded over the internet, so know your dealer.

Simplest invocation:
Sets up on the target system as an EL 6, Ubuntu 12 386, and Debian 7 64bit repository.

```puppet
include pe_repo
```
Complicated setup:
Setup a mirror of packages, but build the repos outside of the base invocation instead.
Also, install pe-httpd, because this is running on an agent that has access to the repo.

```puppet
class { 'pe_repo':
  puppet_master => "pm.not.this.box.com",
  enable_linux => false, # this doesn't call the pe_repo::repo defined type here, we want to customize it
  package_mirror => $::fqdn, # this server
  install_httpd => true,
  repo_port => 8080,
}

pe_repo::repo { 'debian-7-amd64':
  baseurl => "https://your.own.mirror/pe/releases",
  pe_version => '3.0.1',
}
```
License
-------


Contact
-------


Support
-------

Please log tickets and issues at our [Projects site](http://projects.example.com)
