# Class: pe_puppetdb::database
#
# This class manages a PE postgresql database instance suitable for use with PE
# puppetdb. It uses the `puppetlabs/puppetlabs-pe_postgresql` puppet module
# for getting the postgres server up and running, and then also for creating
# the pe-puppetdb database instance and user account.
#
# Parameters:
#   ['database_name']        - The name of the database instance to connect to.
#                              (defaults to `pe-puppetdb`)
#   ['database_username']    - The name of the database user to connect as.
#                              (defaults to `pe-puppetdb`)
#   ['database_password']    - The password for the database user.
#                              (defaults to `pe-puppetdb`)
#   ['tablespace_name']      - The name of puppetdb tablespace.
#   ['tablespace_location']  - The location of puppetdb tablespace.
#
# Actions:
# - Manages a postgres database instance for use by puppetdb
#
# Requires:
# - `puppetlabs/puppetlabs-pe_postgresql`
# - `puppetlabs/puppetlabs-stdlib`
#
# Sample Usage:
#   class { 'pe_puppetdb::database': }
#
class pe_puppetdb::database(
  $database_name       = $pe_puppetdb::params::database_name,
  $database_username   = $pe_puppetdb::params::database_username,
  $database_password   = $pe_puppetdb::params::database_password,
  $tablespace_name     = $pe_puppetdb::params::tablespace_name,
  $tablespace_location = $pe_puppetdb::params::tablespace_location,
) inherits pe_puppetdb::params {
  include pe_postgresql
  include postgresql::params

  # PostgreSQL configuration
  $database_config_hash = pe_puppetdb_safe_hiera_hash('pe_puppetdb::database::database_config_hash', $pe_puppetdb::params::default_database_settings)


  # 'memorysize' fact in bytes (can be used in database_config_hash)
  $memorysize_in_bytes = to_bytes($memorysize)

  # reserved memory for PuppetDB (can be used in database_config_hash)
  # '0 + x' is used for conversion to integer
  $reserved_non_postgresql_memory_in_bytes = 0 + pe_puppetdb_safe_hiera('pe_puppetdb::database::reserved_non_postgresql_memory_in_bytes', $pe_puppetdb::params::default_reserved_non_postgresql_memory_in_bytes)

  $include_basename = 'postgresql_puppetdb_extras.conf'
  $include_file     = "${postgresql::params::confdir}/${include_basename}"

  # set kernel.shmmax to 50% of total RAM to be able to set shared_buffers to an appropriate value
  $shmmax = $memorysize_in_bytes / 2

  sysctl { 'kernel.shmmax':
    ensure    => present,
    permanent => 'yes',
    value     => $shmmax,
  }

  # Template uses:
  #   - $database_config_hash
  file { $include_file:
    content => template('pe_puppetdb/hash_to_conf.erb'),
    notify  => Service['postgresqld'],
    require => Sysctl['kernel.shmmax'],
    owner   => 'pe-postgres',
    group   => 'pe-postgres',
    mode    => '0600',
  }

  # TODO: convert these to postgresql::server::config_entry resources
  file_line { 'postgresql_include_puppetdb_extras':
    ensure  => present,
    path    => "${postgresql::params::confdir}/postgresql.conf",
    line    => "include '${include_basename}'",
    require => File[$include_file],
    notify  => Service['postgresqld'],
  }

  postgresql::server::tablespace { $tablespace_name:
    location => $tablespace_location,
  } ->
  postgresql::server::role { $database_username:
    password_hash => postgresql_password($database_username, $database_password),
  } ->
  postgresql::server::database { $database_name:
    owner      => $database_username,
    tablespace => $tablespace_name,
    encoding   => 'utf8',
    locale     => 'en_US.utf8',
  }

}
