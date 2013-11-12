require 'puppet/util/puppetdb_validator'
require 'puppet/util/ini_file'

Facter.add(:puppetdb_server_status) do
  puppet_conf_file = Puppet[:config]
  break unless File.exists?(puppet_conf_file)
  puppet_conf_file_ini = Puppet::Util::IniFile.new(puppet_conf_file)
  break unless puppet_conf_file_ini.section_names.include?('master')
  setcode do
    puppetdb_conf_file = File.join(Puppet[:confdir], 'puppetdb.conf')

    if puppet_conf_file_ini.get_value('master', 'storeconfigs') == 'true' && puppet_conf_file_ini.get_value('master', 'storeconfigs_backend') == 'puppetdb'
      'configured'
    else
      if File.exists?(puppetdb_conf_file)
        puppetdb_conf_file_ini = Puppet::Util::IniFile.new(puppetdb_conf_file)
        puppetdb_server = puppetdb_conf_file_ini.get_value('main', 'server')
        puppetdb_port = puppetdb_conf_file_ini.get_value('main', 'port')

        signed_ca_file = File.join(Puppet[:signeddir], puppetdb_server + '.pem')

        if File.exists?(signed_ca_file)
          validator = Puppet::Util::PuppetdbValidator.new(puppetdb_server, puppetdb_port)
          if validator.attempt_connection
            'ready_to_configure'
          else
            'puppetdb_server_unreachable'
          end
        else
          'puppetdb_server_not_signed_yet'
        end
      else
        'puppetdb_conf_not_present'
      end
    end
  end
end
