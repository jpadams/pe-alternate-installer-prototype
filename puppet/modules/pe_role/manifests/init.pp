# == Class: pe_role
#
# The pe_role class is a top-level variable aggregator and dependency anchor.
# Other classes in the pe_role module inherit pe_role and use its variable
# values for their defaults.
#
# === Parameters
#
# [*puppetca*]
#   The resolveable name to use for the Puppet Certificate Authority role when
#   configuring applicable roles.
#
# [*puppetmaster*]
#   The resolvable name to use for the Puppet Master service.
#
# [*puppetconsole*]
#   The resolvable name to use for the Puppet Console service.
#
# [*puppetconsoledb*]
#   The resolevable name of the database backend used by the Puppet Console
#   service.
#
# [*puppetinventory*]
#   The resolveable name of the Puppet Inventory service. If in doubt just
#   set this to the same value as puppetmaster.
#
# [*puppetfilebucket*]
#   The resolvable name of the Puppet Filebucket service. If in doubt just
#   set this to the same value as puppetmaster.
#
# [*puppetdb*]
#   The resolvable name of the PuppetDB service.
#
# [*console_login_username*]
#   The login name that will be initially configured on the Puppet Console
#   when the Puppet Console is set up on a new node. This should be in the
#   form of an email address (or should at least match an email address
#   regex).
#
# [*console_login_password*]
#   The login password complimenting console_login_username.
#
# [*consoleauth_username*]
#   The database username for the consoleauth database. This parameter is
#   used when setting up the Puppet Console service, for the console-auth
#   application.
#
# [*consoleauth_password*]
#   The database username for the consoleauth database. This parameter is
#   used when setting up the Puppet Console service, for the console-auth
#   application.
#
# [*console_username*]
#   The database username for the console database. This parameter is used
#   when setting up the Puppet Console service, for the dashboard application.
#
# [*console_password*]
#   The database password for the console database. This parameter is used
#   when setting up the Puppet Console service, for the dashboard application.
#
# [*mysql_root_password*]
#   The root password for the MySQL database used as a backend for the
#   various Puppet Console applications. This is consumed by the
#   pe_role::puppetconsoledb class, if that class is used.
#
# === Examples
#
# There are two ways to use this module. The first way is to use Hiera for
# all parameters. Alternatively, the class can be declared explicitely.
#
# Example 1 (all parameters provided in Hiera):
#
#     include pe_role
#
# Example 2
#
#     class { 'pe_role':
#       puppetca               => 'puppetca.example.com',
#       puppetmaster           => 'puppet.example.com',
#       puppetconsole          => 'puppetconsole.example.com',
#       puppetconsoledb        => 'puppetconsoledb.example.com',
#       puppetinventory        => 'puppetinventory.example.com',
#       puppetfilebucket       => 'puppetfilebucket.example.com',
#       puppetdb               => 'puppetdb.example.com',
#       console_login_username => 'console@example.com',
#       console_login_password => 'Pupp3+4lif3',
#       consoleauth_username   => 'console_auth',
#       consoleauth_password   => 'authzlite',
#       console_username       => 'console',
#       console_password       => 'elosnoc0',
#       mysql_root_password    => 'miiSEQUEL',
#       pe_version             => '3.1.0'
#     }
#
# === Authors
#
# Puppet Labs
#
# Original author:
#   Reid Vandewiele <reid@puppetlabs.com>
#
# === Copyright
#
# Copyright 2013 Puppet Labs, unless otherwise noted
#
class pe_role (
  $puppetca                  = undef,
  $puppetmaster              = undef,
  $puppetconsole             = undef,
  $puppetconsole_db          = undef,
  $puppetinventory           = undef,
  $puppetfilebucket          = undef,
  $puppetdb                  = undef,
  $puppetdb_db               = undef,
  $console_login_username    = undef,
  $console_login_password    = undef,
  $consoleauth_username      = undef,
  $consoleauth_password      = undef,
  $console_username          = undef,
  $console_password          = undef,
  $puppetdb_username         = undef,
  $puppetdb_password         = undef,
  $pe_version                = '3.1.0',
  $puppetmaster_cert_prefix  = 'pe-internal-puppetmaster',
  $puppetconsole_cert_prefix = 'pe-internal-dashboard',
) {

  anchor { 'pe_role::setup_database':  }

  file { '/opt/puppet/pe_version':
    ensure  => file,
    mode    => '0644',
    content => "${pe_version}\n",
  }

}
