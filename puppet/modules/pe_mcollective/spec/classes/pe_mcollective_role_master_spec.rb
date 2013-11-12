require 'spec_helper'

describe 'pe_mcollective::role::master' do
  before :all do
    @facter_facts = {
      'osfamily'          => 'RedHat',
      'lsbmajdistrelease' => '6',
      'puppetversion'     => '2.7.19 (Puppet Enterprise 2.7.0)',
      'fact_stomp_server' => 'testagent',
      'fact_stomp_port'   => '9999',
      'is_pe'             => 'true',
      'stomp_password'    => '0123456789abcdef',
      'fqdn'              => 'masternode.rspec',
      'clientcert'        => 'awesomecert',
    }
  end

  let(:facts) { @facter_facts }

  def public_key(certname)
    "/etc/puppetlabs/puppet/ssl/public_keys/#{certname}.pem"
  end

  def private_key(certname)
    "/etc/puppetlabs/puppet/ssl/private_keys/#{certname}.pem"
  end

  def cert(certname)
    "/etc/puppetlabs/puppet/ssl/certs/#{certname}.pem"
  end

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
      expect { subject }.to raise_error(Puppet::Error, /pe_mcollective puppetmaster role cannot be applied on Windows/)
    end
  end

  context "validating parameters" do
    context "activemq_heap_mb" do
      context "when not a number" do
        let(:params) { { 'activemq_heap_mb' => 'five' } }

        it "fails to compile" do
          expect { subject }.to raise_error(Puppet::Error, /activemq_heap_mb parameter must be a number/)
        end
      end

      context "when units are specified" do
        let(:params) { { 'activemq_heap_mb' => '1024mb' } }

        it "fails to compile" do
          expect { subject }.to raise_error(Puppet::Error, /activemq_heap_mb parameter must be a number/)
        end
      end
    end

    context "mcollective_enable_stomp_ssl" do
      let(:params) { { 'mcollective_enable_stomp_ssl' => '5' } }

      it "fails to compile if it's not boolean" do
        expect { subject }.to raise_error(Puppet::Error, /not a boolean/)
      end
    end
  end

  context "when the parameters are valid" do
    it { should include_class('pe_mcollective::ca') }
    it { should include_class('pe_mcollective::activemq') }
    it { should include_class('pe_mcollective::client::peadmin') }
    it { should_not include_class('pe_mcollective::server') }
    it { should_not include_class('pe_mcollective::client::puppet_dashboard') }
  end

  context "as a CA" do
    it "should manage the existence of the server/client PEM files" do
      should contain_pe_mcollective__puppet_certificate('pe-internal-mcollective-servers')
      should contain_pe_mcollective__puppet_certificate('pe-internal-peadmin-mcollective-client')
      should contain_pe_mcollective__puppet_certificate('pe-internal-puppet-console-mcollective-client')
    end

    context "when activemq ssl is disabled" do
      let(:params) { { 'mcollective_enable_stomp_ssl' => false } }

      it { should_not contain_pe_mcollective__puppet_certificate('pe-internal-broker') }
      it { should_not contain_java_ks('puppetca:truststore') }
      it { should_not contain_java_ks('testagent:keystore') }
    end

    context "when activemq ssl is enabled" do
      let(:params) { { 'mcollective_enable_stomp_ssl' => true } }

      it { should contain_pe_mcollective__puppet_certificate('pe-internal-mcollective-servers') }
      it { should contain_pe_mcollective__puppet_certificate('pe-internal-peadmin-mcollective-client') }
      it { should contain_pe_mcollective__puppet_certificate('pe-internal-puppet-console-mcollective-client') }

      it { should contain_pe_mcollective__puppet_certificate('pe-internal-broker') }

      it do
        should contain_java_ks('puppetca:truststore').with({
          'certificate' => cert('ca'),
          'target'      => '/etc/puppetlabs/activemq/broker.ts',
        })
      end

      it do
        should contain_java_ks('testagent:keystore').with({
          'certificate' => cert('pe-internal-broker'),
          'private_key' => private_key('pe-internal-broker'),
          'target'      => '/etc/puppetlabs/activemq/broker.ks',
        })
      end
    end
  end

  context "as an ActiveMQ server" do
    it { should contain_service('pe-activemq').with('ensure' => 'running', 'enable' => true) }
    it { should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content /brokerName="awesomecert"/ }
    it { should contain_file('/etc/puppetlabs/activemq/activemq-wrapper.conf') }

    context "with stomp SSL enabled" do
      let(:params) { { 'mcollective_enable_stomp_ssl' => true } }

      it "should disable NIO" do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content %r{transportConnector name="stomp\+ssl" uri="stomp\+ssl:\/\/}
      end
    end

    context "with stomp SSL disabled" do
      let(:params) { { 'mcollective_enable_stomp_ssl' => false } }

      it "should enable NIO" do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content %r{transportConnector name="stomp\+nio" uri="stomp\+nio:\/\/}
      end
    end
  end

  context 'as a scaling ActiveMQ server' do
    context 'with default brokerName' do
      let (:params) { { 'activemq_brokers' => ['master1','master2'] } }

      it 'should have the certname as the brokerName' do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /brokerName="awesomecert"/
        )
      end

      it 'should have the brokers as connectors' do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master1-topics"/
        )
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master1-queues"/
        )
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master2-topics"/
        )
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master2-queues"/
        )
      end
    end

    context 'with a custom brokername' do
      let (:params) { {
        'activemq_brokers'    => ['master1','master2'],
        'activemq_brokername' => 'broker1'
      } }

      it 'should have the custom brokerName' do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /brokerName="broker1"/
        )
      end
    end

    context 'with a custom network ttl' do
      let (:params) { {
        'activemq_brokers'     => ['master1','master2'],
        'activemq_network_ttl' => '42'
      } }

      it 'sets the network ttl to 42' do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /networkTTL="42"/
        )
      end
    end
    context "with a custom brokername, brokers, and network ttl via facts" do
      let :facts do
        @facter_facts.merge(
          "activemq_brokers"     => "master3,master4",
          "activemq_network_ttl" => "24"
        )
      end

      it 'sets the network ttl to 24' do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /networkTTL="24"/
        )
      end
      it 'should have the brokers as connectors' do
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master3-topics"/
        )
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master3-queues"/
        )
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master4-topics"/
        )
        should contain_file('/etc/puppetlabs/activemq/activemq.xml').with_content(
          /name="awesomecert-to-master4-queues"/
        )
      end
    end
  end

  context "managing the peadmin client" do
    it { should contain_user('peadmin').with('home' => '/var/lib/peadmin') }

    it do
      should contain_file('/var/lib/peadmin/.bashrc.custom').with({
        'ensure' => 'file',
        'owner'  => 'peadmin',
        'group'  => 'peadmin',
        'mode'   => '0644',
      })
    end

    it { should contain_file('/etc/puppetlabs/mcollective/client.cfg').with('ensure' => 'absent') }
    it { should contain_file('/var/lib/peadmin/.mcollective.d/peadmin-private.pem').with('source' => private_key('pe-internal-peadmin-mcollective-client'), 'mode' => '0600') }
    it { should contain_file('/var/lib/peadmin/.mcollective.d/peadmin-public.pem').with('source' => public_key('pe-internal-peadmin-mcollective-client'), 'mode' => '0644') }
    it { should contain_file('/var/lib/peadmin/.mcollective.d/peadmin-cert.pem').with('source' => cert('pe-internal-peadmin-mcollective-client'), 'mode' => '0644') }
    it { should contain_file('/var/lib/peadmin/.mcollective.d/peadmin-cacert.pem').with('source' => cert('ca'), 'mode' => '0644') }
    it { should contain_file('/var/lib/peadmin/.mcollective.d/mcollective-public.pem').with('source' => public_key('pe-internal-mcollective-servers')) }

    context "client.cfg" do
      def should_have_setting(setting, value)
        should contain_file(client_cfg).with_content(%r[^#{Regexp.escape(setting)}\s*=\s*#{Regexp.escape(value)}$])
      end

      let(:client_cfg) { '/var/lib/peadmin/.mcollective' }

      context "configuring the security provider" do
        it { should_have_setting('securityprovider', 'ssl') }
        it { should_have_setting('plugin.ssl_serializer', 'yaml') }

        it { should_have_setting('plugin.ssl_client_private', '/var/lib/peadmin/.mcollective.d/peadmin-private.pem') }
        it { should_have_setting('plugin.ssl_client_public', '/var/lib/peadmin/.mcollective.d/peadmin-public.pem') }
        it { should_have_setting('plugin.ssl_server_public', '/var/lib/peadmin/.mcollective.d/mcollective-public.pem') }
      end

      it { should_have_setting('main_collective', 'mcollective') }
      it { should_have_setting('factsource', 'yaml') }
      it { should_have_setting('plugin.yaml', '/etc/puppetlabs/mcollective/facts.yaml') }
      it { should_have_setting('libdir', '/opt/puppet/libexec/mcollective/') }
      it { should_have_setting('logfile', '/var/lib/peadmin/.mcollective.d/client.log') }
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
          it { should_have_setting('plugin.activemq.pool.1.ssl.ca', '/var/lib/peadmin/.mcollective.d/peadmin-cacert.pem') }
          it { should_have_setting('plugin.activemq.pool.1.ssl.key', '/var/lib/peadmin/.mcollective.d/peadmin-private.pem') }
          it { should_have_setting('plugin.activemq.pool.1.ssl.cert', '/var/lib/peadmin/.mcollective.d/peadmin-cert.pem') }
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
