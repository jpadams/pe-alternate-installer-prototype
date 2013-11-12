# Puppet Enterprise PuppetDB Module

This module is a wrapper for puppetdb and pe_postgresql modules. It provides a simple way to get a PE puppetdb instance up and running within Puppet Enterprise. It will install and configure all necessary packages, including the database PostgreSQL server and instance.

# Quick Start

### Single Node Setup

This approach assumes you will run everything (PostgreSQL, PuppetDB, puppet master) all on the same node. In this case, your manifest will look like:

    node puppetmaster {
      # Configure pe_puppetdb and its postgres database
      class { 'pe_puppetdb': }
      # Configure the puppet master to use puppetdb
      class { 'puppetdb::master::config': }
    }

You can provide some parameters for these classes if you’d like more control, but that is literally all that it will take to get you up and running with the default configuration.

### Multiple Node Setup

This approach is for those who prefer not to install PuppetDB on the same node as the puppet master. You may even choose to run the puppetdb server on a different node from the PostgreSQL database that it uses to store its data.
 
**This is an example of a very basic 2-node setup for PuppetDB.**

This node is our puppet master:

    node puppet {
      # Configure the puppet master to use puppetdb
      class { 'puppetdb::master::config':
        puppetdb_server => 'puppetdb',
      }
    }

This node is our main puppetdb server:

    node puppetdb {
      # Configure pe_puppetdb and its postgres database
      class { 'pe_puppetdb': }
    }
This should be all it takes to get a 2-node, distributed installation of PuppetDB up and running.

# Customization

Hiera data sources can be used to override default settings for PostgreSQL or Java VM.

### PostgreSQL

##### Default settings

checkpoint_segments = 16  
effective_cache_size = `60% of memory available for PostgreSQL`  
log_min_duration_statement = 5000  
maintenance_work_mem = 256MB  
shared_buffers = `25% of memory available for PostgreSQL`  
wal_buffers = 8MB  
work_mem = 4MB  

##### Override settings

Hiera property `pe_puppetdb::database::database_config_hash` determines PostgreSQL override settings in hash format.

Syntax:
- hash key   - PostgreSQL setting name
- hash value - another hash that can contain:
  - `value`   - fixed value; it has higher priority than `min` or `formula`
  - `min`     - minimal value; if result of `formula` is less than `min` then `min` is used 
  - `formula` - arithmetical expression which can contain any fact, `memorysize_in_bytes` or `reserved_non_postgresql_memory_in_bytes`; the formula is evaluated in ruby using `eval`

Example: to set `max_connections` to `150` the `pe_postgresql_settings` property needs to be set to `{ 'max_connections' => { 'value' => 150 } }`

### Java VM

##### Default options

-Xmx256m -Xms256m

##### Override options

Hiera property `pe_puppetdb::java_args` determines Java VM override options in hash format.

Syntax:
- hash key   - fixed part of a Java VM option
- hash value - variable part of the option

Example: to set `-Xmx512m` option the `pe_puppetdb::java_args` property needs to be set to `{ '-Xmx' => '512m' }`
