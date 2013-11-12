require 'spec_helper'

describe 'pe_mcollective' do
  before :all do
    @facter_facts = {
      'osfamily'              => 'RedHat',
      'lsbmajdistrelease'     => '6',
      'puppetversion'         => '3.2.1 (Puppet Enterprise 3.0.0)',
      'pe_major_version'      => '3',
      'fact_stomp_server'     => 'testagent',
      'fact_stomp_port'       => '9999',
      'is_pe'                 => 'true',
      'stomp_password'        => '0123456789abcdef',
    }
  end

  let :facts do
    @facter_facts
  end

  let :wrapper do
    '/etc/puppetlabs/activemq/activemq-wrapper.conf'
  end

  let :amq_xml do
    '/etc/puppetlabs/activemq/activemq.xml'
  end

  context "for a PE Windows agent" do
    let :facts do
      @facter_facts.merge({
        'osfamily' => 'Windows',
      })
    end
    it { should contain_class 'pe_mcollective' }
    it { should contain_class 'pe_mcollective::params' }
    it { should contain_class 'pe_mcollective::role::agent' }
    it { should_not contain_class 'pe_mcollective::role::master' }
    it { should_not contain_class 'pe_mcollective::role::console' }
  end

  context "for a PE agent" do
    it { should contain_class 'pe_mcollective' }
    it do should contain_class('pe_mcollective::role::agent').with({
      'warn_on_nonpe_agents' => true,
      'warn_on_nonpe3_agents' => true,
    })
    end
  end

end
