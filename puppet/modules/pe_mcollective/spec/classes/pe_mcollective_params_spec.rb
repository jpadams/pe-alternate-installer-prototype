require 'spec_helper'

describe 'pe_mcollective::params' do
  before :all do
    @facter_facts = {
      'osfamily'              => 'RedHat',
      'lsbmajdistrelease'     => '6',
      'puppetversion'         => '2.7.19 (Puppet Enterprise 2.7.0)',
      'fact_stomp_server'     => 'testagent',
      'fact_stomp_port'       => '6163',
      'is_pe'                 => 'true',
      'stomp_password'        => '0123456789abcdef',
    }
  end

  let :facts do
    @facter_facts
  end

  it "should not contain any resources" do
    subject.resources.map(&:ref).should =~ %w{Class[main] Stage[main] Class[Settings] Class[Pe_mcollective::Params]}
  end
end
