require 'spec_helper'

describe "pe_mcollective::role::agent" do
  before :all do
    @facter_facts = {
      'osfamily'              => 'RedHat',
      'lsbmajdistrelease'     => '6',
      'puppetversion'         => '3.0.0 (Puppet Enterprise 3.2.1)',
      'pe_major_version'      => '3',
      'fact_stomp_server'     => 'testagent',
      'fact_stomp_port'       => '9999',
      'is_pe'                 => 'true',
      'stomp_password'        => '0123456789abcdef',
    }
  end

  let(:facts) { @facter_facts }

  context "for a non-PE node" do
    let(:facts) { @facter_facts.merge('is_pe' => 'false') }

    it { should_not include_class('pe_mcollective::server') }

    context "warn_on_nonpe_agents true" do
      let(:params) { { 'warn_on_nonpe_agents' => true } }
      it { should contain_notify 'pe_mcollective-un_supported_platform' }
    end

    context "warn_on_nonpe_agents false" do
      let(:params) { { 'warn_on_nonpe_agents' => false } }
      it { should_not contain_notify 'pe_mcollective-un_supported_platform' }
    end
  end

  context "for a non-PE 3 node" do
    let(:facts) { @facter_facts.merge('pe_major_version' => '2') }

    it { should_not include_class('pe_mcollective::server') }

    context "warn_on_nonpe3_agents true" do
      let(:params) { { 'warn_on_nonpe3_agents' => true } }
      it { should contain_notify 'pe_mcollective-non_pe_3_agent' }
    end

    context "warn_on_nonpe3_agents false" do
      let(:params) { { 'warn_on_nonpe3_agents' => false } }
      it { should_not contain_notify 'pe_mcollective-non_pe_3_agent' }
    end
  end

  context "for a PE Windows node" do
    let :facts do
      @facter_facts.merge({
        'osfamily' => 'Windows',
        'common_appdata' => 'C:\ProgramData'
      })
    end

    it { should include_class('pe_mcollective::server') }
    it { should contain_file('refresh-mcollective-metadata.bat').
      with(:path => /C:.ProgramData.PuppetLabs.mcollective.etc.refresh-mcollective-metadata.bat/,
           :owner => 'S-1-5-32-544',
           :group => 'S-1-5-18',
           :mode  => '0775')
    }
    it { should contain_exec('bootstrap mcollective metadata').
      with_command(/C:.ProgramData.PuppetLabs.mcollective.etc.refresh-mcollective-metadata.bat/)
    }
    it { should contain_scheduled_task('pe-mcollective-metadata').
      with_command(/C:.ProgramData.PuppetLabs.mcollective.etc.refresh-mcollective-metadata.bat/) }

    it { should contain_file('mcollective-private.pem').
      with(:owner => 'S-1-5-32-544', :group => 'S-1-5-18', :mode => '0660')
    }

    it { should contain_file('C:\ProgramData/PuppetLabs/mcollective/etc/plugins/mcollective') }
    it { should contain_file('C:\ProgramData/PuppetLabs/mcollective/etc/plugins') }
  end

  context "on solaris" do
    let(:facts) { @facter_facts.merge('operatingsystem' => 'solaris') }

    it do
      should contain_exec('Solaris: pe-mcollective log rotation').
        with_command("/usr/bin/echo '# pe-mcollective log rotation rule\n/var/log/pe-mcollective/mcollective.log -C 14 -c -p 1w' >> /etc/logadm.conf")
    end
  end

  it { should contain_service('pe-mcollective').with(:ensure => 'running', :enable => true) }
  it { should contain_file('/opt/puppet/sbin/refresh-mcollective-metadata') }
  it { should contain_cron('pe-mcollective-metadata').with_command('/opt/puppet/sbin/refresh-mcollective-metadata') }
  it { should contain_file('/etc/puppetlabs/mcollective/ssl/clients/mcollective-public.pem').with(:ensure => 'absent') }

  it { should contain_file('mcollective-private.pem').
    with(:owner => '0', :group => '0', :mode  => '0600')
  }
  it { should contain_file('mcollective-public.pem') }
  it { should contain_file('mcollective-cert.pem') }
  it { should contain_file('mcollective-cacert.pem') }

  it { should contain_file('/opt/puppet/libexec/mcollective/mcollective') }

  it { should include_class('pe_mcollective::server') }

  context "server.cfg" do
    def should_have_setting(setting, value)
      should contain_file(server_cfg).with_content(%r[^#{Regexp.escape(setting)}\s*=\s*#{Regexp.escape(value)}$])
    end

    let(:server_cfg) { '/etc/puppetlabs/mcollective/server.cfg' }

    it { should contain_file(server_cfg).with_mode('0600') }

    context "configuring mcollective properties" do
      context "with default parameters " do
        it { should_have_setting('registerinterval', '600') }
      end

      context "with a custom registration interval" do
        let(:params) { {'mcollective_registerinterval' => '1234' } }
        it { should_have_setting('registerinterval', '1234') }
      end
    end

    context "configuring the security provider" do
      it { should_have_setting('securityprovider', 'ssl') }
      it { should_have_setting('plugin.ssl_serializer', 'yaml') }

      it { should_have_setting('plugin.ssl_server_private', '/etc/puppetlabs/mcollective/ssl/mcollective-private.pem') }
      it { should_have_setting('plugin.ssl_server_public', '/etc/puppetlabs/mcollective/ssl/mcollective-public.pem') }
      it { should_have_setting('plugin.ssl_client_cert_dir', '/etc/puppetlabs/mcollective/ssl/clients/') }
    end

    context "on Windows" do
      let(:installdir)     { 'C:\Program Files (x86)\Puppet Labs\Puppet Enterprise' }
      let(:common_appdata) { 'C:\ProgramData' }
      let(:vardir)         { "#{common_appdata}/PuppetLabs/puppet/var" }
      let(:facts) do
        @facter_facts.merge("operatingsystem"        => "windows",
                            "common_appdata"         => common_appdata,
                            "env_windows_installdir" => installdir)
      end

      it { should_have_setting('classesfile', "#{vardir}/state/classes.txt") }
      it { should_have_setting('daemonize', '1') }
      it { should_have_setting('logfile', "#{common_appdata}/PuppetLabs/mcollective/var/log/mcollective.log") }
      it { should_have_setting('plugin.puppet.command', "\"#{installdir}/bin/puppet.bat\" agent") }
    end

    context "on other platforms" do
      it { should_have_setting('classesfile', '/var/opt/lib/pe-puppet/classes.txt') }
      it { should_have_setting('daemonize', '1') }
      it { should_have_setting('logfile', '/var/log/pe-mcollective/mcollective.log') }
      it { should_have_setting('plugin.puppet.command', '/opt/puppet/bin/puppet agent') }
      it { should_have_setting('plugin.puppet.config', '/etc/puppetlabs/puppet/puppet.conf') }
    end

    it { should_have_setting('main_collective', 'mcollective') }
    it { should_have_setting('factsource', 'yaml') }
    it { should_have_setting('plugin.yaml', '/etc/puppetlabs/mcollective/facts.yaml') }
    it { should_have_setting('libdir', '/opt/puppet/libexec/mcollective/') }

    it { should_have_setting('plugin.puppet.splay', 'true') }
    it { should_have_setting('plugin.puppet.splaylimit', '120') }

    context "managing the connector" do
      it { should_have_setting('connector', 'activemq') }

      context "with the default pool" do
        it { should_have_setting('plugin.activemq.pool.size', '1') }
        it { should_have_setting('plugin.activemq.pool.1.host', 'testagent') }
        it { should_have_setting('plugin.activemq.pool.1.port', '9999') }
        it { should_have_setting('plugin.activemq.pool.1.user', 'mcollective') }
        it { should_have_setting('plugin.activemq.pool.1.password', '0123456789abcdef') }
        it { should_have_setting('plugin.activemq.pool.1.ssl', 'true') }
        it { should_have_setting('plugin.activemq.pool.1.ssl.ca', '/etc/puppetlabs/mcollective/ssl/mcollective-cacert.pem') }
        it { should_have_setting('plugin.activemq.pool.1.ssl.key', '/etc/puppetlabs/mcollective/ssl/mcollective-private.pem') }
        it { should_have_setting('plugin.activemq.pool.1.ssl.cert', '/etc/puppetlabs/mcollective/ssl/mcollective-cert.pem') }
      end

      context "specifying pool members with a fact" do
        let(:facts) { @facter_facts.merge("fact_stomp_server" => "abc,def,ghi") }

        it { should_have_setting('plugin.activemq.pool.size', '3') }

        %w[abc def ghi].each_with_index do |host, idx|
          i = idx + 1
          it { should_have_setting("plugin.activemq.pool.#{i}.host", host) }
          it { should_have_setting("plugin.activemq.pool.#{i}.port", '9999') }
          it { should_have_setting("plugin.activemq.pool.#{i}.user", 'mcollective') }
          it { should_have_setting("plugin.activemq.pool.#{i}.password", '0123456789abcdef') }
        end
      end

      context "specifying pool members with parameters" do
        let(:params) do
          {
            "stomp_servers"  => %w[foo bar],
            "stomp_port"     => "12345",
            "stomp_user"     => "anyone",
            "stomp_password" => "supersecret",
            "mcollective_enable_stomp_ssl" => "false",
          }
        end

        it { should_have_setting('plugin.activemq.pool.size', '2') }

        %w[foo bar].each_with_index do |host, idx|
          i = idx + 1
          it { should_have_setting("plugin.activemq.pool.#{i}.host", host) }
          it { should_have_setting("plugin.activemq.pool.#{i}.port", '12345') }
          it { should_have_setting("plugin.activemq.pool.#{i}.user", 'anyone') }
          it { should_have_setting("plugin.activemq.pool.#{i}.password", 'supersecret') }
          it { should_have_setting("plugin.activemq.pool.#{i}.ssl", 'false') }
        end
      end
    end
  end
end
