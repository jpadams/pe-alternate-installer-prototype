# This is an example of how to get pe_puppetdb up and running on a separate node.

# This node is puppet master
node puppet {
  # Configure the puppet master to use puppetdb
  class { 'puppetdb::master::config':
    puppetdb_server => 'puppetdb',
  }
}

# This node is puppetdb server
node puppetdb {
  # Configure pe_puppetdb and its postgres database
  class { 'pe_puppetdb': }
}