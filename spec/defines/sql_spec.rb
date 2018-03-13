require 'spec_helper'
require 'shared_contexts'

describe 'freeradius::sql' do
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
      database: nil,
      password: nil,
      # server: "localhost",
      # login: "radius",
      # radius_db: "radius",
      # num_sql_socks: "${thread[pool].max_servers}",
      # query_file: "${modconfdir}/${.:name}/main/${dialect}/queries.conf",
      # custom_query_file: :undef,
      # lifetime: "0",
      # max_queries: "0",
      # ensure: "present",
      # acct_table1: "radacct",
      # acct_table2: "radacct",
      # postauth_table: "radpostauth",
      # authcheck_table: "radcheck",
      # authreply_table: "radreply",
      # groupcheck_table: "radgroupcheck",
      # groupreply_table: "radgroupreply",
      # usergroup_table: "radusergroup",
      # deletestalesessions: "yes",
      # sqltrace: "no",
      # sqltracefile: "${logdir}/sqllog.sql",
      # connect_failure_retry_delay: "60",
      # nas_table: "nas",
      # read_groups: "yes",
      # port: "3306",
      # readclients: "no",
      # pool_start: "1",
      # pool_min: "1",
      # pool_spare: "1",
      # pool_idle_timeout: "60",
      # pool_connect_timeout: "3.0",

    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  it do
    is_expected.to contain___freeradius__config('$name-queries.conf').with(
      source: :undef,
    )
  end
  
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
  
  it do
    is_expected.to contain_logrotate__rule('sqltrace').with(
      path: '$::freeradius::params::fr_logpath/${logdir}/sqllog.sql',
      rotate_every: 'week',
      rotate: '1',
      create: true,
      compress: true,
      missingok: true,
      postrotate: 'kill -HUP `cat $freeradius::fr_pidfile`',
    )
  end
  
end
