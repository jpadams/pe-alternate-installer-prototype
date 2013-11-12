# Class: pe_puppetdb::params
#
#   The pe_puppetdb configuration settings.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class pe_puppetdb::params
inherits puppetdb::params {
  $database             = 'postgres'
  $database_host        = 'localhost'
  $database_port        = '5432'
  $database_name        = 'pe-puppetdb'
  $database_username    = 'pe-puppetdb'
  $database_password    = ''
  $tablespace_name      = 'pe-puppetdb'
  $tablespace_location  = '/opt/puppet/var/lib/pgsql/9.2/puppetdb'

  $node_ttl             = '7d'

  $puppetdb_package     = 'pe-puppetdb'
  $puppetdb_service     = 'pe-puppetdb'
  $confdir              = '/etc/puppetlabs/puppetdb/conf.d'
  $puppet_service_name  = 'pe-httpd'
  $puppet_confdir       = '/etc/puppetlabs/puppet'
  $terminus_package     = 'pe-puppetdb-terminus'
  $embedded_subname     = 'file:/opt/puppet/share/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'

  $default_reserved_non_postgresql_memory_in_bytes = 536870912

  # Default PE PostgreSQL settings
  $default_database_settings =
    { 'effective_cache_size' => { 'min' => 128, 'formula' => '(@memorysize_in_bytes - @reserved_non_postgresql_memory_in_bytes) / (1024 * 1024) * 0.60', unit => 'MB' },
      'shared_buffers' => { 'min' => 32, 'formula' => '(@memorysize_in_bytes - @reserved_non_postgresql_memory_in_bytes) / (1024 * 1024) * 0.25', unit => 'MB' },
      'maintenance_work_mem' => { 'value' => 256, unit => 'MB' },
      'wal_buffers' => { 'value' => 8, unit => 'MB' },
      'work_mem' => { 'value' => 4, unit => 'MB' },
      'checkpoint_segments' => { 'value' => 16 },
      'log_min_duration_statement' => { 'value' => 5000 },
    }

  # Default PE PuppetDB Java VM options
  $default_jvm_args =
  {
    '-Xmx' => '256m',
    '-Xms' => '256m',
  }
}
