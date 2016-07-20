require 'spec_helper'
require 'shared_contexts'

describe 'freeradius' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  #include_context :hiera

  
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
      #:control_socket => false,
      #:max_servers => "4096",
      #:max_requests => "4096",
      #:mysql_support => false,
      #:perl_support => false,
      #:utils_support => false,
      #:ldap_support => false,
      #:krb5_support => false,
      #:wpa_supplicant => false,
      #:winbind_support => false,
      #:syslog => false,
      #:log_auth => 'no',
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  it do
    is_expected.to contain_file('radiusd.conf')
      .with(
        'content' => 'template(freeradius/radiusd.conf.fr$freeradius::fr_version.erb)',
        'group'   => '$freeradius::fr_group',
        'mode'    => '0640',
        'name'    => '$freeradius::fr_basepath/radiusd.conf',
        'notify'  => 'Service[$freeradius::fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_file('[$freeradius::fr_basepath/statusclients.d, $freeradius::fr_basepath, $freeradius::fr_basepath/conf.d, $freeradius::fr_basepath/attr.d, $freeradius::fr_basepath/users.d, $freeradius::fr_basepath/policy.d, $freeradius::fr_basepath/dictionary.d, $freeradius::fr_basepath/scripts]')
      .with(
        'ensure'  => 'directory',
        'group'   => '$freeradius::fr_group',
        'mode'    => '0750',
        'notify'  => 'Service[$freeradius::fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_file('[$freeradius::fr_basepath/certs, $freeradius::fr_basepath/clients.d, $freeradius::fr_basepath/sites-enabled, $freeradius::fr_basepath/sites-available, $freeradius::fr_basepath/instantiate]')
      .with(
        'ensure'  => 'directory',
        'group'   => '$freeradius::fr_group',
        'mode'    => '0750',
        'notify'  => 'Service[$freeradius::fr_service]',
        'owner'   => 'root',
        'purge'   => 'true',
        'recurse' => 'true',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_freeradius__module('eap')
      .with(
        'ensure' => 'absent'
      )
  end
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/policy.conf')
      .with(
        'group'   => '$freeradius::fr_group',
        'mode'    => '0640',
        'notify'  => 'Service[$freeradius::fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_concat__fragment('policy_header')
      .with(
        'content' => 'policy {\\n',
        'order'   => '10',
        'target'  => '$freeradius::fr_basepath/policy.conf'
      )
  end
  it do
    is_expected.to contain_concat__fragment('policy_footer')
      .with(
        'content' => '}\\n',
        'order'   => '99',
        'target'  => '$freeradius::fr_basepath/policy.conf'
      )
  end
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/proxy.conf')
      .with(
        'group'   => '$freeradius::fr_group',
        'mode'    => '0640',
        'notify'  => 'Service[$freeradius::fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_concat__fragment('proxy_header')
      .with(
        'content' => '# Proxy config\\n\\n',
        'order'   => '05',
        'target'  => '$freeradius::fr_basepath/proxy.conf'
      )
  end
  it do
    is_expected.to contain_concat('$freeradius::fr_modulepath/attr_filter')
      .with(
        'group'   => '$freeradius::fr_group',
        'mode'    => '0640',
        'notify'  => 'Service[$freeradius::fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_concat__fragment('attr-default')
      .with(
        'content' => 'template(freeradius/attr_default.fr$freeradius::fr_version.erb)',
        'order'   => '10',
        'target'  => '$freeradius::fr_modulepath/attr_filter'
      )
  end
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/dictionary')
      .with(
        'group'   => '$freeradius::fr_group',
        'mode'    => '0640',
        'owner'   => 'root',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_concat__fragment('dictionary_header')
      .with(
        'order'  => '10',
        'source' => 'puppet:///modules/freeradius/dictionary.header',
        'target' => '$freeradius::fr_basepath/dictionary'
      )
  end
  it do
    is_expected.to contain_concat__fragment('dictionary_footer')
      .with(
        'order'  => '90',
        'source' => 'puppet:///modules/freeradius/dictionary.footer',
        'target' => '$freeradius::fr_basepath/dictionary'
      )
  end
  it do
    is_expected.to contain_package('freeradius')
      .with(
        'ensure' => 'installed',
        'name'   => '$freeradius::fr_package'
      )
  end
  it do
    is_expected.to contain_service('$freeradius::fr_service')
      .with(
        'enable'     => 'true',
        'ensure'     => 'running',
        'hasrestart' => 'true',
        'hasstatus'  => '$freeradius::fr_service_has_status',
        'name'       => '$freeradius::fr_service',
        'require'    => '[Exec[radiusd-config-test], File[radiusd.conf], User[$freeradius::fr_user], Package[$freeradius::fr_package]]'
      )
  end
  it do
    is_expected.to contain_user('$freeradius::fr_user')
      .with(
        'ensure'  => 'present',
        'groups'  => '$winbind_support ? { true => $freeradius::fr_wbpriv_user, default => undef }',
        'require' => 'Package[$freeradius::fr_package]'
      )
  end
  it do
    is_expected.to contain_group('$freeradius::fr_group')
      .with(
        'ensure'  => 'present',
        'require' => 'Package[$freeradius::fr_package]'
      )
  end
  it do
    is_expected.to contain_freeradius__module('always')
      .with(      )
  end
  it do
    is_expected.to contain_freeradius__module('detail')
      .with(      )
  end
  it do
    is_expected.to contain_freeradius__module('detail.log')
      .with(      )
  end
  it do
    is_expected.to contain_file('[$freeradius::fr_logpath, $freeradius::fr_logpath/radacct]')
      .with(
        'mode'    => '0750',
        'require' => 'Package[$freeradius::fr_package]'
      )
  end
  it do
    is_expected.to contain_file('$freeradius::fr_logpath/radius.log')
      .with(
        'group'   => '$freeradius::fr_group',
        'owner'   => '$freeradius::fr_user',
        'require' => '[Package[$freeradius::fr_package], User[$freeradius::fr_user], Group[$freeradius::fr_group]]',
        'seltype' => 'radiusd_log_t'
      )
  end
  it do
    is_expected.to contain_logrotate__rule('radacct')
      .with(
        'compress'      => 'true',
        'create'        => 'false',
        'missingok'     => 'true',
        'path'          => '$freeradius::fr_logpath/radacct/*/*.log',
        'postrotate'    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
        'rotate'        => '7',
        'rotate_every'  => 'day',
        'sharedscripts' => 'true'
      )
  end
  it do
    is_expected.to contain_logrotate__rule('checkrad')
      .with(
        'compress'      => 'true',
        'create'        => 'true',
        'missingok'     => 'true',
        'path'          => '$freeradius::fr_logpath/checkrad.log',
        'postrotate'    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
        'rotate'        => '1',
        'rotate_every'  => 'week',
        'sharedscripts' => 'true'
      )
  end
  it do
    is_expected.to contain_logrotate__rule('radiusd')
      .with(
        'compress'      => 'true',
        'create'        => 'true',
        'missingok'     => 'true',
        'path'          => '$freeradius::fr_logpath/radius*.log',
        'postrotate'    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
        'rotate'        => '26',
        'rotate_every'  => 'week',
        'sharedscripts' => 'true'
      )
  end
  it do
    is_expected.to contain_file('[$freeradius::fr_basepath/certs/dh, $freeradius::fr_basepath/certs/random]')
      .with(
        'require' => 'Exec[dh, random]'
      )
  end
  it do
    is_expected.to contain_exec('dh')
      .with(
        'command' => 'openssl dhparam -out $freeradius::fr_basepath/certs/dh 1024',
        'creates' => '$freeradius::fr_basepath/certs/dh',
        'path'    => '/usr/bin'
      )
  end
  it do
    is_expected.to contain_exec('random')
      .with(
        'command' => 'dd if=/dev/urandom of=$freeradius::fr_basepath/certs/random count=10 >/dev/null 2>&1',
        'creates' => '$freeradius::fr_basepath/certs/random',
        'path'    => '/bin'
      )
  end
  it do
    is_expected.to contain_exec('radiusd-config-test')
      .with(
        'command'     => 'sudo radiusd -XC | grep 'Configuration appears to be OK.' | wc -l',
        'logoutput'   => 'on_failure',
        'path'        => '[/bin/, /sbin/, /usr/bin/, /usr/sbin/]',
        'refreshonly' => 'true',
        'returns'     => '0'
      )
  end
  it do
    is_expected.to contain_file('[$freeradius::fr_basepath/sites-available/default, $freeradius::fr_basepath/sites-available/inner-tunnel, $freeradius::fr_basepath/clients.conf, $freeradius::fr_basepath/sql.conf]')
      .with(
        'content' => '# FILE INTENTIONALLY BLANK\\n',
        'group'   => '$freeradius::fr_group',
        'mode'    => '0644',
        'notify'  => 'Service[$freeradius::fr_service]',
        'owner'   => 'root',
        'require' => '[Package[$freeradius::fr_package], Group[$freeradius::fr_group]]'
      )
  end
  it do
    is_expected.to contain_package('freeradius-mysql')
      .with(
        'ensure' => 'installed'
      )
  end
  it do
    is_expected.to contain_package('freeradius-perl')
      .with(
        'ensure' => 'installed'
      )
  end
  it do
    is_expected.to contain_package('freeradius-utils')
      .with(
        'ensure' => 'installed'
      )
  end
  it do
    is_expected.to contain_package('freeradius-ldap')
      .with(
        'ensure' => 'installed'
      )
  end
  it do
    is_expected.to contain_package('freeradius-krb5')
      .with(
        'ensure' => 'installed'
      )
  end
  it do
    is_expected.to contain_package('wpa_supplicant')
      .with(
        'ensure' => 'installed',
        'name'   => '$freeradius::fr_wpa_supplicant'
      )
  end
  it do
    is_expected.to contain_syslog__rule('radiusd-log')
      .with(
        'command' => 'if $programname == 'radiusd' then $freeradius::fr_logpath/radius.log\\n&~',
        'order'   => '12'
      )
  end
  it do
    is_expected.to contain_exec('delete-radius-rpmnew')
      .with(
        'command' => 'find $freeradius::fr_basepath -name *.rpmnew -delete',
        'onlyif'  => 'find $freeradius::fr_basepath -name *.rpmnew | grep rpmnew',
        'path'    => '[/bin/, /sbin/, /usr/bin/, /usr/sbin/]'
      )
  end
  it do
    is_expected.to contain_exec('delete-radius-rpmsave')
      .with(
        'command' => 'find $freeradius::fr_basepath -name *.rpmsave -delete',
        'onlyif'  => 'find $freeradius::fr_basepath -name *.rpmsave | grep rpmsave',
        'path'    => '[/bin/, /sbin/, /usr/bin/, /usr/sbin/]'
      )
  end
end
