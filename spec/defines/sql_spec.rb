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
      :database => 'place_value_here',
      :password => 'place_value_here',
      #:server => "localhost",
      #:login => "radius",
      #:radius_db => "radius",
      #:num_sql_socks => "${thread[pool].max_servers}",
      #:query_file => "sql/${database}/dialup.conf",
      #:custom_query_file => "",
      #:lifetime => "0",
      #:max_queries => "0",
      #:ensure => present,
      #:acct_table1 => "radacct",
      #:acct_table2 => "radacct",
      #:postauth_table => "radpostauth",
      #:authcheck_table => "radcheck",
      #:authreply_table => "radreply",
      #:groupcheck_table => "radgroupcheck",
      #:groupreply_table => "radgroupreply",
      #:usergroup_table => "radusergroup",
      #:deletestalesessions => "yes",
      #:sqltrace => "no",
      #:sqltracefile => "${logdir}/sqltrace.sql",
      #:connect_failure_retry_delay => "60",
      #:nas_table => "nas",
      #:read_groups => "yes",
      #:port => "3306",
      #:readclients => "no",
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_file('$::osfamily ? { RedHat => /etc/raddb, Debian => /etc/freeradius, default => /etc/raddb }/$fr_version ? { 2 => modules, 3 => mods-enabled, default => modules }/XXreplace_meXX')
      .with(
        'content' => 'template(freeradius/sql.conf.fr$fr_version.erb)',
        'ensure'  => 'present',
        'group'   => '$::osfamily ? { RedHat => radiusd, Debian => freerad, default => radiusd }',
        'mode'    => '0640',
        'notify'  => 'Service[$fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$fr_package], Group[$fr_group]]'
      )
  end
  it do
    is_expected.to contain___freeradius__config('XXreplace_meXX-queries.conf')
      .with(
        'source' => ''
      )
  end
  it do
    is_expected.to contain_logrotate__rule('sqltrace')
      .with(
        'compress'     => 'true',
        'create'       => 'true',
        'missingok'    => 'true',
        'path'         => '$::osfamily ? { RedHat => /var/log/radius, Debian => /var/log/freeradius, default => /var/log/radius }/${logdir}/sqltrace.sql',
        'postrotate'   => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
        'rotate'       => '1',
        'rotate_every' => 'week'
      )
  end
end
