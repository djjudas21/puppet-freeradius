require 'spec_helper'
require 'shared_contexts'

describe 'freeradius::krb5' do
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
      :keytab => 'place_value_here',
      :principal => 'place_value_here',
      #:start => "${thread[pool].start_servers}",
      #:min => "${thread[pool].min_spare_servers}",
      #:max => "${thread[pool].max_servers}",
      #:spare => "${thread[pool].max_spare_servers}",
      #:ensure => "present",
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_file('$::osfamily ? { RedHat => /etc/raddb, Debian => /etc/freeradius, default => /etc/raddb }/$fr_version ? { 2 => modules, 3 => mods-enabled, default => modules }/XXreplace_meXX')
      .with(
        'content' => 'template(freeradius/krb5.erb)',
        'ensure'  => 'present',
        'group'   => '$::osfamily ? { RedHat => radiusd, Debian => freerad, default => radiusd }',
        'mode'    => '0640',
        'notify'  => 'Service[$fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$fr_package], Group[$fr_group]]'
      )
  end
end
