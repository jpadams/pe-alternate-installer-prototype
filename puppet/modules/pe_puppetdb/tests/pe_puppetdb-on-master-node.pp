# This is an example of how to get pe_puppetdb up and running on the same node
# where your puppet master is running.

# Configure pe_puppetdb and its postgres database
include pe_puppetdb

# Configure the puppet master to use puppetdb
include puppetdb::master::config
