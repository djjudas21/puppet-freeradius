require 'spec_helper'
require 'shared_contexts'

describe 'freeradius::module::ldap' do
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
      basedn: nil,
      # ensure: "present",
      # server: ["localhost"],
      # port: "389",
      # identity: :undef,
      # password: :undef,
      # sasl: {},
      # valuepair_attribute: :undef,
      # update: :undef,
      # edir: :undef,
      # edir_autz: :undef,
      # user_base_dn: "${..base_dn}",
      # user_filter: "(uid=%{%{Stripped-User-Name}:-%{User-Name}})",
      # user_sasl: {},
      # user_scope: :undef,
      # user_sort_by: :undef,
      # user_access_attribute: :undef,
      # user_access_positive: :undef,
      # group_base_dn: "${..base_dn}",
      # group_filter: "(objectClass=posixGroup)",
      # group_scope: :undef,
      # group_name_attribute: :undef,
      # group_membership_filter: :undef,
      # group_membership_attribute: "memberOf",
      # group_cacheable_name: :undef,
      # group_cacheable_dn: :undef,
      # group_cache_attribute: :undef,
      # group_attribute: :undef,
      # profile_filter: :undef,
      # profile_default: :undef,
      # profile_attribute: :undef,
      # client_base_dn: "${..base_dn}",
      # client_filter: "(objectClass=radiusClient)",
      # client_scope: :undef,
      # read_clients: :undef,
      # dereference: :undef,
      # chase_referrals: "yes",
      # rebind: "yes",
      # use_referral_credentials: "no",
      # session_tracking: :undef,
      # timeout: "10",
      # timelimit: "3",
      # idle: "60",
      # probes: "3",
      # interval: "3",
      # ldap_debug: "0x0028",
      # starttls: "no",
      # cafile: :undef,
      # certfile: :undef,
      # keyfile: :undef,
      # random_file: :undef,
      # requirecert: "allow",
      # start: "${thread[pool].start_servers}",
      # min: "${thread[pool].min_spare_servers}",
      # max: "${thread[pool].max_servers}",
      # spare: "${thread[pool].max_spare_servers}",
      # uses: "0",
      # retry_delay: "30",
      # lifetime: "0",
      # idle_timeout: "60",
      # connect_timeout: "3.0",

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  it do
    is_expected.to contain_file('$::freeradius::params::fr_basepath/mods-available/$name').with(
      ensure: 'present',
      mode: '0640',
      owner: 'root',
      group: '$::freeradius::params::fr_group',
      content: [],
      require: ['Package[$::freeradius::params::fr_package]', 'Group[$::freeradius::params::fr_group]'],
      notify: 'Service[$::freeradius::params::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_file('$::freeradius::params::fr_modulepath/$name').with(
      ensure: 'link',
      target: '../mods-available/$name',
    )
  end
  
end
