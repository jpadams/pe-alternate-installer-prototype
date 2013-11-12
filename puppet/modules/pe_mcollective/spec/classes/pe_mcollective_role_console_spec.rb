require 'spec_helper'

describe "pe_mcollective::role::console" do
  before :all do
    @facter_facts = {
      'osfamily'              => 'RedHat',
      'lsbmajdistrelease'     => '6',
      'puppetversion'         => '2.7.19 (Puppet Enterprise 2.7.0)',
      'fact_stomp_server'     => 'testagent',
      'fact_stomp_port'       => '9999',
      'is_pe'                 => 'true',
      'stomp_password'        => '0123456789abcdef',
    }
  end

  let(:facts) { @facter_facts }

  context "for a non-PE node" do
    let :facts do
      @facter_facts.merge({
        'is_pe' => false
      })
    end

    it "fails to compile" do
      expect { subject }.to raise_error(Puppet::Error, /not a Puppet Enterprise agent/)
    end
  end

  context "for a PE Windows node" do
    let :facts do
      @facter_facts.merge({
        'osfamily' => 'Windows'
      })
    end

    it "fails to compile" do
      expect { subject }.to raise_error(Puppet::Error, /console role cannot be applied on a Windows platform/)
    end
  end

  context "managing the puppet-dashboard client" do
    it { should contain_user('puppet-dashboard').with('home' => '/opt/puppet/share/puppet-dashboard') }
    it { should contain_file('/opt/puppet/share/puppet-dashboard').with('mode' => '0755') }

    it do
      should contain_file('/opt/puppet/share/puppet-dashboard/.bashrc.custom').with({
        'ensure' => 'file',
        'owner'  => 'puppet-dashboard',
        'group'  => 'puppet-dashboard',
        'mode'   => '0600',
      })
    end

    it { should contain_file('/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-private.pem').with('mode' => '0600') }
    it { should contain_file('/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-public.pem').with('mode' => '0644') }
    it { should contain_file('/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cert.pem').with('mode' => '0644') }
    it { should contain_file('/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cacert.pem').with('mode' => '0644') }

    context "client.cfg" do
      def should_have_setting(setting, value)
        should contain_file(client_cfg).with_content(%r[^#{Regexp.escape(setting)}\s*=\s*#{Regexp.escape(value)}$])
      end

      let(:client_cfg) { '/opt/puppet/share/puppet-dashboard/.mcollective' }

      it { should contain_file(client_cfg).with_mode('0600') }

      context "configuring the security provider" do
        it { should_have_setting('securityprovider', 'ssl') }
        it { should_have_setting('plugin.ssl_serializer', 'yaml') }

        it { should_have_setting('plugin.ssl_client_private', '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-private.pem') }
        it { should_have_setting('plugin.ssl_client_public', '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-public.pem') }
        it { should_have_setting('plugin.ssl_server_public', '/opt/puppet/share/puppet-dashboard/.mcollective.d/mcollective-public.pem') }
      end

      it { should_have_setting('main_collective', 'mcollective') }
      it { should_have_setting('factsource', 'yaml') }
      it { should_have_setting('plugin.yaml', '/etc/puppetlabs/mcollective/facts.yaml') }
      it { should_have_setting('libdir', '/opt/puppet/libexec/mcollective/') }
      it { should_have_setting('logfile', '/var/log/pe-puppet-dashboard/mcollective_client.log') }
      it { should_have_setting('loglevel', 'info') }

      context "managing the connector" do
        it { should_have_setting('connector', 'activemq') }

        context "with the default pool" do
          it { should_have_setting('plugin.activemq.pool.size', '1') }
          it { should_have_setting('plugin.activemq.pool.1.host', 'testagent') }
          it { should_have_setting('plugin.activemq.pool.1.port', '9999') }
          it { should_have_setting('plugin.activemq.pool.1.user', 'mcollective') }
          it { should_have_setting('plugin.activemq.pool.1.password', '0123456789abcdef') }
          it { should_have_setting('plugin.activemq.pool.1.ssl', 'true') }
          it { should_have_setting('plugin.activemq.pool.1.ssl.ca', '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cacert.pem') }
          it { should_have_setting('plugin.activemq.pool.1.ssl.key', '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-private.pem') }
          it { should_have_setting('plugin.activemq.pool.1.ssl.cert', '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cert.pem') }
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
            it { should_have_setting("plugin.activemq.pool.#{i}.ssl", 'true') }
            it { should_have_setting("plugin.activemq.pool.#{i}.ssl.ca", '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cacert.pem') }
            it { should_have_setting("plugin.activemq.pool.#{i}.ssl.key", '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-private.pem') }
            it { should_have_setting("plugin.activemq.pool.#{i}.ssl.cert", '/opt/puppet/share/puppet-dashboard/.mcollective.d/puppet-dashboard-cert.pem') }
          end
        end

        context "specifying pool members with parameters" do
          let(:params) do
            {
              "stomp_servers" => %w[foo bar],
              "stomp_port" => "12345",
              "stomp_user" => "anyone",
              "stomp_password" => "supersecret",
              "mcollective_enable_stomp_ssl" => false,
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
end
