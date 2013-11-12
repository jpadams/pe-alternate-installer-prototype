#pe_role

####Table of Contents

1. [Overview - What is the pe_role module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - Information and instructions on what you need before you start with pe_role](#setup)**<- Reconsider this description**
    * [Deployment Structure - What is available and how best to use it with your environment](#deployment-structure)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pe_role - A walkthrough of the main class you MUST use first](#beginning-with-pe_role)
4. [Tuning - Configuring and using pe_role within your environment](#Tuning)
    * [Class: pe_role::agent](#class-pe_roleagent)
    * [Class: pe_role::mcobroker](#class-pe_rolemcobroker)
    * [Class: pe_role::mcoserver](#class-pe_rolemcoserver)
    * [Class: pe_role::puppetagent](#class-pe_rolepuppetagent)
    * [Class: pe_role::puppetca](#class-pe_rolepuppetca)
    * [Class: pe_role::puppetconsole](#class-pe_rolepuppetconsole)
    * [Class: pe_role::puppetconsoledb](#class-pe_rolepuppetconsoledb)
    * [Class: pe_role::puppetmaster](#class-pe_rolepuppetmaster)
5. [Reference - Some under-the-hood workings of the module](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)

##Overview

The pe_role module provides a quick, streamlined way to assign roles to nodes during initial Puppet Enterprise setup.        

##Module Description

The pe_role module utilizes the submodules `pe_console`, `pe_puppet`, `pe_mcollective`, and others to set up and assign roles during installation and setup of Puppet Enterprise.

This document begins with the basic instructions for setting up a Puppet Enterprise configuration with the module. It will then delve into the details of tuning and configuration options. 

This is the first module you should run in the series of Puppet Install (Enterprise) modules.

##Setup

###Deployment Structure

If you read nothing else in this README, read this section. Your choices in all of the other sections will depend on your answers in this section. 

The roles available through the pe_role module fall into two categories: Stateful Services and Service Pools. 

**Stateful Services** are roles that are not clustered; there cannot be more than one of these. By default, these services will all be setup on a single active host. While it is possible to disperse them across more than one host, this practice is not advised. 

* `puppetca` - This is the puppet certificate authority service. It is an infrastructure that can sign new certificates. Typically, the puppet CA role is filled by a designated puppet master.
* `puppetfilebucket` - This is the puppet file bucket service. It is used to cache copies of files that Puppet needs to overwrite when enforcing configuration. The filebucket can be used to reference what local changes to a file triggered a Puppet remediation.
* `puppetconsoledb` - This is the backend MySQL database host used by the PE console.

**Service Pools** are comprised of identical, horizontally scaled instances. They are roles that can be clustered and used more than once.

* `puppet` - This is the puppet master service. It compiles configuration catalogs for agents and presents a REST API for core Puppet services.
* `puppetconsole` - This is the Puppet Enterprise console service. It is the Graphical User Interface for classifying nodes, viewing reports, and issuing real-time node information, requests, and directives.
* `puppetinventory` - This is the puppet master service to use for inventory queries. It is used to store and retrieve cached Facter information for agent nodes in the Puppet infrastructure.

When you go to structure your PE deployment, you must ask yourself:

* How many of each service pool role do you want want?
    * How many nodes do you have? 
    * How many puppet masters do you need given your above answer?
    * How many puppet console services do you need given your above answer? 
    * How many puppet masters for inventory queries given the number of nodes and puppet masters you plan on having?  
* Where will these roles live? 
    *  What node(s) will you install however many puppet masters you decided to have on?
    * What node(s) will the console service(s) be on? 
    * What node(s) will the puppet master(s) dealing with inventory queries be on?
    * What node will you use for the stageful service roles? 
    * Will you co-house some service pool roles with one another? 
    * Will you co-house some service pool roles with the stageful service roles?  

###Setup Requirements 

You must have the Puppet Enterprise bundle downloaded and present on the system you are using as your deployment master. **TODO: (Original TODO requested workflow diagram from Reid) Check with E.S. about potentially just linking to Getting Started Guide here. "For more information about the overall process of the PE Installer bundle, please see the [Getting Started Guide](some link)."**

This module allows you the option of using Hiera to populate the parameters and makes calls to the `hiera` function. It is therefore critical that Hiera be set up. If Hiera is not set up and you attempt to use this module, Puppet will crash with errors referring to a missing `$confdir/hiera.yaml` file. For instructions on how to install Hiera, please [refer here](http://docs.puppetlabs.com/hiera/1/installing.html).

**TODO: Re-reading this section, it is abrupt and doesn't make sense immediately. More explanatory intro is required.** As a quick-start, an example configuration file (hiera.yaml) and example data file (common.yaml) are included in the `ext/` directory of this module. To boostrap a minimal deployment, the files can be copied directly onto the system prior to running Puppet. 

    # cp ${modulepath}/pe_role/ext/hiera.yaml /etc/puppetlabs/puppet/
    # mkdir /etc/puppetlabs/puppet/hieradata
    # cp ${modulepath}/pe_role/ext/common.yaml /etc/puppetlabs/puppet/hieradata/

###Beginning with pe_role

The pe_role module can be used in two ways: you may either utilize Hiera to populate the class parameters or you may specify customized values for the parameters yourself. 

Before you begin setting up specific roles, you must configure the `pe_role` class. 

####Class: pe_role

The `pe_role` class is a top-level variable aggregator and dependency anchor; all other classes in the module inherit `pe_role` and use its variable values for their defaults.

*Note:* The `pe_role` class will function with almost all of the default parameter values that are built-in, with the exception of the passwords and the console username. This means that you could, feasibly, specify only the various passwords and the console username values and the module would run.

If you have chosen to utilize Hiera, you need only declare the class. 

    include pe_role
    
If you are not using Hiera or would like to use custom values

    class { 'pe_role':
       puppetca               => 'puppetca.example.com',
       puppetmaster           => 'puppet.example.com',
       puppetconsole          => 'puppetconsole.example.com',
       puppetconsoledb        => 'puppetconsoledb.example.com',
       puppetinventory        => 'puppetinventory.example.com',
       puppetfilebucket       => 'puppetfilebucket.example.com',
       console_login_username => 'console@example.com',
       console_login_password => 'Pupp3+4lif3',
       consoleauth_username   => 'console_auth',
       consoleauth_password   => 'authzlite',
       console_username       => 'console',
       console_password       => 'elosnoc0',
       mysql_root_password    => 'miiSEQUEL',
     }
     
At this point, no configuration changes to the system have actually been specified. Rather, you have enabled all of the *other* pe_role module classes, preparing the way to deploy any of the more specific roles. In other words, if this is the only class you declare in this module, nothing will happen.  

Parameters within `pe_role`:

#####`puppetca`

The resolvable name to use for the Puppet Certificate Authority role when configuring applicable roles.

#####`puppetmaster`

The resolvable name to use for the Puppet Master service.

#####`puppetconsole`

The resolvable name to use for the Puppet Console service.

#####`puppetconsoledb`

The resolvable name of the database backend used by the Puppet Console service.

#####`puppetinventory`

The resolvable name of the Puppet Inventory service. If in doubt, set this to the same value as `puppetmaster`.

#####`puppetfilebucket`

The resolvable name of the Puppet Filebucket service. If in doubt, set this to the same value as `puppetmaster`.

#####`console_login_username`

The login name to initially configure on the Puppet Enterprise console when the console is set up on a new node. This should be in the form of an e-mail address (or should at least match an e-mail address regex).

#####`console_login_password`*

The login password complimenting `console_login_username`.

#####`consoleauth_username`

The database username for the console-auth database. This parameter is used when setting up the Puppet Console service for the console-auth application. 

#####`consoleauth_password`*

The database password for the console-auth database. This parameter is used when setting up the Puppet Console service for the console-auth application. 

#####`console_username`*

The database username for the console database. This parameter is used when setting up the Puppet Console service for the dashboard application.

#####`console_password`*

The database password for the console database. This parameter is used when setting up the Puppet Console service for the dashboard application.

#####`mysql_root_password`*

The root password for the MySQL database being used as a backend for the various Puppet Console applications. This is consumed by the `pe_role::puppetconsoledb` class if that class is used.

**Required* 
**TODO: Should the "Required" be moved up?**

##Tuning

The `pe_role` class enables all of the other classes in the module to function. However, you must declare each class in order to access the role established by that class. **<- That sentence is a bit crap. TODO** 

Most of the additional classes in the pe_role module will use the parameters set in the `pe_role` class to populate their own parameters. The classes that offer additional parameters will have their parameters called out below. **TODO: That last sentence is also a bit crap.**

###Class: pe_role::agent

This class allows you to manage the functionality of the `pe_role::puppetagent` and `pe_role::mcoserver` classes all at once. You cannot directly pass in parameters, as the class expects any customization data to come from Hiera. If you require custom parameters or are not using Hiera, you must use `pe_role::puppetagent` and `pe_role::mcoserver` separately and omit `pe_role::agent` altogether. 

###Class: pe_role::puppetagent

The `pe_role::puppetagent` class will set up and configure a puppet agent on a node.

####Parameters in `pe_role::puppet agent`

#####`master_host`

The puppet master the agent will connect to.

#####`master_port`

The port of the puppet master.  

#####`ca_host`

The certificate authority the puppet agent will use. 

#####`ca_port`

The port to use for the certificate authority. 

#####`certname`

The name of certifcation (agent ID) to use. The default value for this parameter is the current certname the agent is using to contact the master.

#####`config_file`

This parameter is not meant for configuration. It allows the class to work with any version of Puppet. 

###Class: pe_role::mcobroker

The `pe_role::mcobroker` class configures a node with an instance of ActiveMQ, the middleware used by MCollective.

###Class: pe_role::mcoserver

The `pe_role::mcoserver` class configures an MCollective server connected to the appropriate MCollective broker and installs MCollective plugins.  

###Class: pe_role::puppetca

The `pe_role::puppetca` class extends the role established in `pe-role::puppetmaster` by adding the capability of serving as a puppet certificate authority. The `puppetca` role is [stateful](#deployment-structure).

###Class: pe_role::puppetconsole

The `pe_role::puppetconsole` class is a top-level role classifier that configures a node to run an instance of the PE Console application, the graphical user interface for viewing Puppet reports and specifying classification information. It achieves this by leveraging the values set in `pe_role` and the functionality provided by the `pe_console` module.

####Parameters in `pe_role::puppetconsole`:

#####`dashboard_certname`

The certificate name to use for the Puppet Dashboard service. This parameter will create a certificate on the system if one does not already exist, and it will be used to communicate with the puppet master service(s).

#####`dashboard_db_host`

The resolvable name to use to reach the database backend for the Puppet Dashboard service.

#####`dashboard_db_port`

The port to use to connect to the Puppet Dashboard service's database backend.

#####`dashboard_db_database`

The database name for the Puppet Dashboard service to use.

#####`dashboard_db_username`

The username for logging in to the database backend of the Puppet Dashboard service.

#####`dashboard_db_password`

The password for logging in to the database backend of the Puppet Dashboard service.

#####`dashboard_root`

The directory in which to install the Puppet Dashboard application.

#####`consoleauth_db_host`

The resolvable name to use to reach the database backend for the console-auth service.

#####`consoleauth_db_port`

The port to use to connect to the console-auth service's database backend.

#####`consoleauth_db_database`

The database name used by the console-auth service.

#####`consoleauth_db_username`

The username for logging in to the database backend for the console-auth service.

#####`consoleauth_db_password`

The password for logging in to the database backend for the console-auth service.

#####`consoleauth_login_username`
   
The username to pre-configure with administrator rights to services that use console-auth. If specified, this login username will be added to the console-auth database as an administrator. It should be in the form of an email address.

#####`consoleauth_login_password`
   
The password for the user specified in `consoleauth_login_username`.

#####`inventory_host`

The resolvable name to use to reach the puppet inventory service.

#####`inventory_port`

The port over which the inventory service is available.

#####`filebucket_host`

The resolvable name to use to reach the puppet filebucket service.

#####`filebucket_port`

The port over which the filebucket service is available.

#####`ca_host`

The resolvable certificate authority hostname or fully qualified domain name.

#####`ca_port`

The port over which the CA service is available.

#####`smtp_host`

The resolvable name of the SMTP mail server.

#####`smtp_username`

If necessary, the username to use when authenticating to the SMTP server.

#####`smtp_password`

If necessary, the password to use when authenticating to the SMTP server.

#####`consoleauth_console_host`**TODO**

The resolvable name of the node running the console.
When configuring the console-auth service, 

#####`casclient_casport`

The port over which the CAS client will connect to the CAS server.

#####`casclient_cashost`

The resolvable name the CAS client will use to connect to the CAS server.

#####`casclient_sessionsecret`

The session secret key for the CAS client.

#####`casclient_sessionkey`

The session key for the CAS client.

#####`casserver_db_host`

The resolvable name the CAS server will use to connect to its database backend.

#####`casserver_db_password`

The password the CAS server will use to authenticate to the database backend.

#####`casserver_db_port`

The port over which the CAS server will connect to the its database backend.

#####`casserver_db_database`

The name of the database the CAS server will use.

#####`casserver_db_username`

The username the CAS server will use to authenticate to the database backend.

###Class: pe_role::puppetconsoledb **TODO: Complete this class and its parameters.**



####Parameters within `pe_role::puppetconsoledb`:



###Class: pe_role::puppetmaster

The `pe_role::puppetmaster` class is a top-level role classifier that sets up the puppet master service. It achieves this by leveraging the default values set in the `pe_role`class and the functionality provided by pe_puppet and pe_httpd modules.

####Parameters within `pe_role::puppetmaster`

#####`ca_host`

The resolvable name to use to reach the Puppet certificate authority service.

#####`ca_port`

The port to use to connect to the Puppet certificate authority service.

#####`certname`

The certificate name to use for the puppet master service; it is used to authenticate communication with the puppet agent system(s). This certificate will be created if it does not exist on the system.

#####`dns_alt_names`

The full list of resolvable names that may be used to connect to the puppet master service. These names will become `subjectAlternativeName`s in the generated certificate for the puppet master service.

#####`confdir`

The Puppet confdir. See the [configuration reference](http://docs.puppetlabs.com/references/latest/configuration.html) for more information on the confdir setting.

#####`config_file`

The location of the `puppet.conf` file.

#####`console_host`

The resolvable name to use to reach the puppet console service. This is primarily used to tell the puppet master service where to send reports via the https report processor.

#####`console_port`

The port to use to connect to the puppet console service when sending reports.

#####`inventory_dbname`

The name of the database used for Active Record storeconfigs. You do not need to use this parameter if you are using PuppetDB or if you are *not* using storeconfigs. 

#####`inventory_dbpassword`

The database password used for Active Record storeconfigs. You do not need to use this parameter if you are using PuppetDB or if you are *not* using storeconfigs.

#####`inventory_dbhost`

The resolvable name used to reach the Active Record storeconfigs database service. You do not need to use this parameter if you are using PuppetDB or if you are *not* using storeconfigs.

#####`inventory_dbuser`

The database username used for Active Record storeconfigs. You do not need to use this parameter if you are using PuppetDB or if you are *not* using storeconfigs.

#####`modulepath`

The modulepath to use for the puppet master service. See the [configuration reference](http://docs.puppetlabs.com/references/latest/configuration.html#modulepath) for more information about the modulepath setting.

#####`puppetdb_host`

The resolvable name used to reach the PuppetDB service, if you are using PuppetDB.

#####`puppetdb_port`

The port to use to connect to the PuppetDB service, if you are using PuppetDB.

##Reference

####Custom function: hiera_or_undef

This function performs a hiera lookup on specified keys. It will
check each key sequentially and return the hiera value found for the first valid key. If no key is valid, the undef keyword will be returned.

This allows default values for class parameters to be specified in Puppet 2.7.x by hiera call, without overriding parameter settings when no key is actually
defined in hiera and allowing the default value to be set to 'undef'.
    
####Custom function: pick_or_undef

This function will perform a [pick](https://github.com/glarizza/puppet-pick) lookup on the specified keys. It will check each key sequentially, and return the first key pick()ed. If no key is selected by pick(), the undef keyword will be returned.

This difference in behavior between pick() and pick_or_undef() allows `pick_or_undef` to be used as the default value for class parameters specified in
Puppet 2.7.x, without overriding parameter settings when no key would otherwise
be matched, thus allowing the default value to fail back to 'undef'.

##Limitations

OS compatibility, etc.

##Bootstrap

Run a command like the following.

    puppet agent --
