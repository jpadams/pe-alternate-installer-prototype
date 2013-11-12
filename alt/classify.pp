# This is a shortcut for creating groups and classes in the PE Console AFTER
# installation.

include pe_role

$modulepath = hiera('pe_role::puppetmaster::modulepath')

$tasks = [
  # "nodeclass:add['pe_role','skip']",
  # "nodegroup:add['PE Role','skip']",
  # "nodegroup:addclass['PE Role','pe_role']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetca','${pe_role::puppetca}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetmaster','${pe_role::puppetmaster}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetconsole','${pe_role::puppetconsole}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetconsole_db','${pe_role::puppetconsole_db}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetinventory','${pe_role::puppetinventory}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetfilebucket','${pe_role::puppetfilebucket}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetdb','${pe_role::puppetdb}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetdb_db','${pe_role::puppetdb_db}']",
  # "nodegroup:addclassparam['PE Role','pe_role','console_login_username','${pe_role::console_login_username}']",
  # "nodegroup:addclassparam['PE Role','pe_role','console_login_password','${pe_role::console_login_password}']",
  # "nodegroup:addclassparam['PE Role','pe_role','consoleauth_username','${pe_role::consoleauth_username}']",
  # "nodegroup:addclassparam['PE Role','pe_role','consoleauth_password','${pe_role::consoleauth_password}']",
  # "nodegroup:addclassparam['PE Role','pe_role','console_username','${pe_role::console_username}']",
  # "nodegroup:addclassparam['PE Role','pe_role','console_password','${pe_role::console_password}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetdb_username','${pe_role::puppetdb_username}']",
  # "nodegroup:addclassparam['PE Role','pe_role','puppetdb_password','${pe_role::puppetdb_password}']",

  "nodeclass:add['pe_role::agent','skip']",
  "nodegroup:add['PE Agent','skip']",
  "nodegroup:addclass['PE Agent','pe_role::agent']",

  "nodeclass:add['pe_role::puppetca','skip']",
  "nodegroup:add['PE Certificate Authority','skip']",
  "nodegroup:addclass['PE Certificate Authority','pe_role::puppetca']",
  "nodegroup:addgroup['PE Certificate Authority','PE Agent']",

  "nodeclass:add['pe_role::puppetmaster','skip']",
  "nodeclass:add['pe_role::mcobroker','skip']",
  "nodegroup:add['PE Master','skip']",
  "nodegroup:addclass['PE Master','pe_role::puppetmaster']",
  "nodegroup:addclass['PE Master','pe_role::mcobroker']",
  "nodegroup:addclassparam['PE Master','pe_role::puppetmaster','modulepath','${modulepath}']",
  "nodegroup:addgroup['PE Master','PE Agent']",

  "nodeclass:add['pe_role::puppetconsole','skip']",
  "nodegroup:add['PE Console','skip']",
  "nodegroup:addclass['PE Console','pe_role::puppetconsole']",
  "nodegroup:addgroup['PE Console','PE Agent']",

  "nodeclass:add['pe_role::database::console','skip']",
  "nodeclass:add['pe_role::database::puppetdb','skip']",
  "nodegroup:add['PE Database','skip']",
  "nodegroup:addclass['PE Database','pe_role::database::console']",
  "nodegroup:addclass['PE Database','pe_role::database::puppetdb']",
  "nodegroup:addgroup['PE Database','PE Agent']",

  "nodeclass:add['pe_role::puppetdb','skip']",
  "nodegroup:add['PE PuppetDB','skip']",
  "nodegroup:addclass['PE PuppetDB','pe_role::puppetdb']",
  "nodegroup:addgroup['PE PuppetDB','PE Agent']",

  "node:addgroup['${::clientcert}','PE Certificate Authority']",
  "node:addgroup['${::clientcert}','PE Master']",
  "node:addgroup['${::clientcert}','PE Console']",
  "node:addgroup['${::clientcert}','PE Database']",
  "node:addgroup['${::clientcert}','PE PuppetDB']",
]

pe_console::rake_task { 'default data':
  task => join($tasks, ' '),
}
