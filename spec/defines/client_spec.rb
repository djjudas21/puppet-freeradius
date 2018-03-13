require 'spec_helper'
require 'shared_contexts'

describe 'freeradius::client' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  let(:title) { 'XXreplace_meXX' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      secret: nil,
      # shortname: "$title",
      # ip: :undef,
      # ip6: :undef,
      # proto: :undef,
      # require_message_authenticator: "no",
      # virtual_server: :undef,
      # nastype: :undef,
      # login: :undef,
      # password: :undef,
      # coa_server: :undef,
      # response_window: :undef,
      # max_connections: :undef,
      # lifetime: :undef,
      # idle_timeout: :undef,
      # redirect: :undef,
      # port: :undef,
      # srcip: :undef,
      # firewall: false,
      # ensure: "present",
      # attributes: [],
      # huntgroups: :undef,

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  it do
    is_expected.to contain_file('$::freeradius::params::fr_basepath/clients.d/$title.conf').with(
      ensure: 'present',
      mode: '0640',
      owner: 'root',
      group: '$::freeradius::params::fr_group',
      content: [],
      require: ['File[$::freeradius::params::fr_basepath/clients.d]', 'Group[$::freeradius::params::fr_group]'],
      notify: 'Service[$::freeradius::params::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_firewall('100-$title-undef-v4').with(
      proto: 'udp',
      dport: :undef,
      action: 'accept',
      source: :undef,
    )
  end
  
  it do
    is_expected.to contain_firewall('100-$title-undef-v6').with(
      proto: 'udp',
      dport: :undef,
      action: 'accept',
      provider: 'ip6tables',
      source: :undef,
    )
  end
  
  it do
    is_expected.to contain_freeradius__huntgroup('huntgroup.client.$title.$index').with(
      
    )
  end
  
end
