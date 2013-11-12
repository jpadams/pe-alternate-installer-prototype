#pe_console

####Table of Contents

1. [Overview - What is the [Modulename] module?](#overview)
2. [Module Description - What does the module do?](#module-description)
3. [Setup - The basics of getting started with [Modulename]](#setup)
    * [What [Modulename] affects](#what-registry-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with [Modulename]](#beginning-with-registry)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

##Overview

Pe_console quickly and simply sets up the Puppet Enterprise Console.       

##Module Description

A brief description of the technology (if applicable) the module is working with, and how the module interacts with that technology. This section should answer the questions: "What does this module *do*?" and "Why would I use it?"

If your module has a range of functionality (installation, configuration, managment, etc.) this is the time to mention it.

##Setup

###What pe_console affects

* A list of files, packages, services, or operations that the module will alter, impact, or execute on a user's system.
* This is a great place to stick any Warnings.

###Setup Requirements

You must have downloaded the Puppet Enterprise bundle and have it present on the system you are running the module on.

While you may run any **PE Deploy** module individually, it is advices that you have run 
	
###Beginning with [Modulename]	

The very basic steps needed for a user to get the module running. 


##Usage

Classes, types, and resources for customizing, configuring and doing the fancy stuff with your module. 


##Reference

###Class: pe_console

This is a top-level wrapper class intended to be used in an environment where most parameters come from hiera. Every default should be undef if it's really just a passthrough to a lower-level class (defaults will be supplied by that lower-level class).

##Limitations

OS compatibility, etc.

##Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can’t access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

You can read the complete module contribution guide [on the Puppet Labs wiki.](http://projects.puppetlabs.com/projects/module-site/wiki/Module_contributing)

##Release Notes **Optional**

If you aren't using changelog. 
