# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_plugin('oscar')

if defined? Oscar
  vagrantdir = File.dirname(__FILE__)
  configdir  = File.expand_path('config', vagrantdir)
  Vagrant.configure('2', &Oscar.run(configdir))
end
