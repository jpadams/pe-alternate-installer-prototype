# Puppetized PE installation prototype

#### Table of Contents

1. [Overview](#overview)
2. [Setup](#setup)
    * [Plugins](#plugins)
    * [Installation](#installation)
    * [Optional: Snapshots](#optional--snapshots)
3. [Usage](#usage)
4. [Reference](#reference)

## Overview

This repository is a Vagrant configuration and associated Puppet code to spin
up a self-contained demonstration environment. The demonstration environment
contains prototype code for installing and configuring Puppet Enterprise using
Puppet.

The [Oscar](https://github.com/adrienthebo/oscar) vagrant plugin is used to
provide YAML based configuration, Puppet Enterprise provisioning, networking,
and name resolution.

The [vagrant-windows](https://github.com/WinRb/vagrant-windows) vagrant plugin
is used to provide Windows support.

The [vagrant-multiprovider-snap](https://github.com/scalefactory/vagrant-multiprovider-snap)
plugin can optionally be used to provide support for creating and rolling back
snapshots.

## Setup

### Plugins

Install VirtualBox 4.2 or newer and Vagrant 1.3 or newer. The following plugins
are also required.

    vagrant plugin install oscar
    vagrant plugin install vagrant-windows

### Installation

Using the Vagrant Stack is as simple as performing a `git clone` on the repo
and running `vagrant up`. A full example checkout and initialization is given
below.

    git clone git@github.com:reidmv/pe-alternate-installer-prototype.git
    cd pe-alternate-installer-prototype

From this point forward everything is a standard Vagrant workflow. Commands
like `vagrant list` will show you the machines defined and avaialble, and
machines can be brought up with `vagrant up` as per usual. In order to get name
resolution working the first time the machines are brought up, also re-run the
"hosts" provisioner.

    vagrant up
    vagrant provision --provision-with hosts

### Optional: Snapshots

The vagrant-multiprovider-snap can be installed in order to provide the ability
to easily snapshot and rollback virtual machine instances.

    vagrant plugin install vagrant-multiprovider-snap

## Usage

This stack is built to demonstrate a prototype PE puppetized installation and
management process. To start, on the first VM run
`/vagrant/alt/puppet-enterprise-alternate-installer`. The help options will
inform you that you need to specify an answers file (one is provided in
`/vagrant/alt/answers.yaml`) and a PE tarball. You will have to download the
tarball yourself.

# Reference

Notes about implementation details may be added here at a later date. Until
then, perusing the code is the best reference for how things have been
implemented.
