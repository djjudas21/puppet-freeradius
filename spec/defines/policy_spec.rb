require 'spec_helper'
require 'shared_contexts'

describe 'freeradius::policy' do
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
      source: nil,
      # order: "50",
      # ensure: "present",

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  it do
    is_expected.to contain_file('$::freeradius::params::fr_basepath/policy.d/$name').with(
      ensure: 'present',
      mode: '0644',
      owner: 'root',
      group: '$::freeradius::params::fr_group',
      source: :undef,
      require: ['Package[$::freeradius::params::fr_package]', 'Group[$::freeradius::params::fr_group]'],
      notify: 'Service[$::freeradius::params::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('policy-$name').with(
      target: '$::freeradius::params::fr_basepath/policy.conf',
      content: '\t$INCLUDE $::freeradius::params::fr_basepath/policy.d/$name\n',
      order: '50',
      require: 'File[$::freeradius::params::fr_basepath/policy.d/$name]',
    )
  end
  
end
