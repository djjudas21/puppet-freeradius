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
      # control_socket: false,
      # max_servers: "4096",
      # max_requests: "4096",
      # mysql_support: false,
      # pgsql_support: false,
      # perl_support: false,
      # utils_support: false,
      # ldap_support: false,
      # dhcp_support: false,
      # krb5_support: false,
      # wpa_supplicant: false,
      # winbind_support: false,
      # log_destination: "files",
      # syslog: false,
      # log_auth: "no",
      # preserve_mods: true,
      # correct_escapes: true,
      # manage_logpath: true,
      # package_ensure: "installed",
      # radacctdir: "$freeradius::params::radacctdir",
    }
  end
  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  
  it do
    is_expected.to contain_notify('This module is only compatible with FreeRADIUS 3.')
  end  
  
  it do
    is_expected.to contain_file('radiusd.conf').with(
      name: '$freeradius::fr_basepath/radiusd.conf',
      mode: '0644',
      owner: 'root',
      group: '$freeradius::fr_group',
      content: [],
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_file(['$freeradius::fr_basepath/statusclients.d', '$freeradius::fr_basepath', '$freeradius::fr_basepath/conf.d', '$freeradius::fr_basepath/attr.d', '$freeradius::fr_basepath/users.d', '$freeradius::fr_basepath/policy.d', '$freeradius::fr_basepath/dictionary.d', '$freeradius::fr_basepath/scripts']).with(
      ensure: 'directory',
      mode: '0755',
      owner: 'root',
      group: '$freeradius::fr_group',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_file(['$freeradius::fr_basepath/certs', '$freeradius::fr_basepath/clients.d', '$freeradius::fr_basepath/listen.d', '$freeradius::fr_basepath/sites-enabled', '$freeradius::fr_basepath/mods-enabled', '$freeradius::fr_basepath/instantiate']).with(
      ensure: 'directory',
      purge: true,
      recurse: true,
      mode: '0755',
      owner: 'root',
      group: '$freeradius::fr_group',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_freeradius__module(['always', 'cache_eap', 'chap', 'detail', 'detail.log', 'digest', 'dynamic_clients', 'echo', 'exec', 'expiration', 'expr', 'files', 'linelog', 'logintime', 'mschap', 'ntlm_auth', 'pap', 'passwd', 'preprocess', 'radutmp', 'realm', 'replicate', 'soh', 'sradutmp', 'unix', 'unpack', 'utf8']).with(
      preserve: true,
    )
  end
  
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/policy.conf').with(
      owner: 'root',
      group: '$freeradius::fr_group',
      mode: '0640',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('policy_header').with(
      target: '$freeradius::fr_basepath/policy.conf',
      content: 'policy {\n',
      order: '10',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('policy_footer').with(
      target: '$freeradius::fr_basepath/policy.conf',
      content: '}\n',
      order: '99',
    )
  end
  
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/templates.conf').with(
      owner: 'root',
      group: '$freeradius::fr_group',
      mode: '0640',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('template_header').with(
      target: '$freeradius::fr_basepath/templates.conf',
      source: 'puppet:///modules/freeradius/template.header',
      order: '05',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('template_footer').with(
      target: '$freeradius::fr_basepath/templates.conf',
      content: '}\n',
      order: '95',
    )
  end
  
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/proxy.conf').with(
      owner: 'root',
      group: '$freeradius::fr_group',
      mode: '0640',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('proxy_header').with(
      target: '$freeradius::fr_basepath/proxy.conf',
      content: '# Proxy config\n\n',
      order: '05',
    )
  end
  
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/mods-available/attr_filter').with(
      owner: 'root',
      group: '$freeradius::fr_group',
      mode: '0640',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_file('$freeradius::fr_modulepath/attr_filter').with(
      ensure: 'link',
      target: '../mods-available/attr_filter',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('attr-default').with(
      target: '$freeradius::fr_basepath/mods-available/attr_filter',
      content: [],
      order: '10',
    )
  end
  
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/dictionary').with(
      owner: 'root',
      group: '$freeradius::fr_group',
      mode: '0640',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('dictionary_header').with(
      target: '$freeradius::fr_basepath/dictionary',
      source: 'puppet:///modules/freeradius/dictionary.header',
      order: '10',
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('dictionary_footer').with(
      target: '$freeradius::fr_basepath/dictionary',
      source: 'puppet:///modules/freeradius/dictionary.footer',
      order: '90',
    )
  end
  
  it do
    is_expected.to contain_concat('$freeradius::fr_basepath/mods-config/preprocess/huntgroups').with(
      owner: 'root',
      group: '$freeradius::fr_group',
      mode: '0640',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
    )
  end
  
  it do
    is_expected.to contain_concat__fragment('huntgroups_header').with(
      target: '$freeradius::fr_basepath/mods-config/preprocess/huntgroups',
      source: 'puppet:///modules/freeradius/huntgroups.header',
      order: '10',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius').with(
      ensure: 'installed',
      name: '$freeradius::fr_package',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius-mysql').with(
      ensure: 'installed',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius-postgresql').with(
      ensure: 'installed',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius-perl').with(
      ensure: 'installed',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius-utils').with(
      ensure: 'installed',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius-ldap').with(
      ensure: 'installed',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius-dhcp').with(
      ensure: 'installed',
    )
  end
  
  it do
    is_expected.to contain_package('freeradius-krb5').with(
      ensure: 'installed',
    )
  end
  
  it do
    is_expected.to contain_package('wpa_supplicant').with(
      ensure: 'installed',
      name: '$freeradius::fr_wpa_supplicant',
    )
  end
  
  it do
    is_expected.to contain_service('$freeradius::fr_service').with(
      ensure: 'running',
      name: '$freeradius::fr_service',
      require: ['Exec[radiusd-config-test]', 'File[radiusd.conf]', 'User[$freeradius::fr_user]', 'Package[$freeradius::fr_package]'],
      enable: true,
      hasstatus: '$freeradius::fr_service_has_status',
      hasrestart: true,
    )
  end
  
  it do
    is_expected.to contain_user('$freeradius::fr_user').with(
      ensure: 'present',
      groups: [],
      require: 'Package[$freeradius::fr_package]',
    )
  end
  
  it do
    is_expected.to contain_group('$freeradius::fr_group').with(
      ensure: 'present',
      require: 'Package[$freeradius::fr_package]',
    )
  end
  
  it do
    is_expected.to contain_rsyslog__snippet('12-radiusd-log').with(
      content: 'if $programname == 'radiusd' then $freeradius::fr_logpath/radius.log\n&~',
    )
  end
  
  it do
    is_expected.to contain_file(['$freeradius::fr_logpath', '$freeradius::fr_logpath/radacct']).with(
      mode: '0750',
      require: 'Package[$freeradius::fr_package]',
    )
  end
  
  it do
    is_expected.to contain_file('$freeradius::fr_logpath/radius.log').with(
      owner: '$freeradius::fr_user',
      group: '$freeradius::fr_group',
      seltype: 'radiusd_log_t',
      require: ['Package[$freeradius::fr_package]', 'User[$freeradius::fr_user]', 'Group[$freeradius::fr_group]'],
    )
  end
  
  it do
    is_expected.to contain_logrotate__rule('radacct').with(
      path: '$freeradius::fr_logpath/radacct/*/*.log',
      rotate_every: 'day',
      rotate: '7',
      create: nil,
      missingok: true,
      compress: true,
      postrotate: 'kill -HUP `cat $freeradius::fr_pidfile`',
      sharedscripts: true,
    )
  end
  
  it do
    is_expected.to contain_logrotate__rule('checkrad').with(
      path: '$freeradius::fr_logpath/checkrad.log',
      rotate_every: 'week',
      rotate: '1',
      create: true,
      missingok: true,
      compress: true,
      postrotate: 'kill -HUP `cat $freeradius::fr_pidfile`',
      sharedscripts: true,
    )
  end
  
  it do
    is_expected.to contain_logrotate__rule('radiusd').with(
      path: '$freeradius::fr_logpath/radius*.log',
      rotate_every: 'week',
      rotate: '26',
      create: true,
      missingok: true,
      compress: true,
      postrotate: 'kill -HUP `cat $freeradius::fr_pidfile`',
      sharedscripts: true,
    )
  end
  
  it do
    is_expected.to contain_file(['$freeradius::fr_basepath/certs/dh', '$freeradius::fr_basepath/certs/random']).with(
      require: 'Exec[dh, random]',
    )
  end
  
  it do
    is_expected.to contain_exec('dh').with(
      command: 'openssl dhparam -out $freeradius::fr_basepath/certs/dh 1024',
      creates: '$freeradius::fr_basepath/certs/dh',
      path: '/usr/bin',
    )
  end
  
  it do
    is_expected.to contain_exec('random').with(
      command: 'dd if=/dev/urandom of=$freeradius::fr_basepath/certs/random count=10 >/dev/null 2>&1',
      creates: '$freeradius::fr_basepath/certs/random',
      path: '/bin',
    )
  end
  
  it do
    is_expected.to contain_exec('radiusd-config-test').with(
      command: 'sudo radiusd -XC | grep 'Configuration appears to be OK.' | wc -l',
      returns: '0',
      refreshonly: true,
      logoutput: 'on_failure',
      path: ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    )
  end
  
  it do
    is_expected.to contain_file(['$freeradius::fr_basepath/clients.conf', '$freeradius::fr_basepath/sql.conf']).with(
      content: '# FILE INTENTIONALLY BLANK\n',
      mode: '0644',
      owner: 'root',
      group: '$freeradius::fr_group',
      require: ['Package[$freeradius::fr_package]', 'Group[$freeradius::fr_group]'],
      notify: 'Service[$freeradius::fr_service]',
    )
  end
  
  it do
    is_expected.to contain_exec('delete-radius-rpmnew').with(
      command: 'find $freeradius::fr_basepath -name *.rpmnew -delete',
      onlyif: 'find $freeradius::fr_basepath -name *.rpmnew | grep rpmnew',
      path: ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    )
  end
  
  it do
    is_expected.to contain_exec('delete-radius-rpmsave').with(
      command: 'find $freeradius::fr_basepath -name *.rpmsave -delete',
      onlyif: 'find $freeradius::fr_basepath -name *.rpmsave | grep rpmsave',
      path: ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    )
  end
end
