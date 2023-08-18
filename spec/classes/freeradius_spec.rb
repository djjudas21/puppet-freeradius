require 'spec_helper'

describe 'freeradius' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'redhat_params'

      let(:facts) { os_facts }

      # Empty params hash by default so we can super().merge
      let(:params) { {} }

      it do
        is_expected.to contain_file('freeradius radiusd.conf')
          .with(
            'group'  => 'radiusd',
            'mode'   => '0644',
            'path'   => '/etc/raddb/radiusd.conf',
            'notify' => 'Service[radiusd]',
            'owner'  => 'root',
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        {
          'freeradius statusclients.d': '/etc/raddb/statusclients.d',
          'freeradius raddb': '/etc/raddb',
          'freeradius conf.d': '/etc/raddb/conf.d',
          'freeradius attr.d': '/etc/raddb/attr.d',
          'freeradius users.d': '/etc/raddb/users.d',
          'freeradius policy.d': '/etc/raddb/policy.d',
          'freeradius dictionary.d': '/etc/raddb/dictionary.d',
          'freeradius scripts': '/etc/raddb/scripts',
          'freeradius mods-config': '/etc/raddb/mods-config',
          'freeradius mods-config/attr_filter': '/etc/raddb/mods-config/attr_filter',
          'freeradius mods-config/preprocess': '/etc/raddb/mods-config/preprocess',
          'freeradius mods-config/sql': '/etc/raddb/mods-config/sql',
          'freeradius sites-available': '/etc/raddb/sites-available',
          'freeradius mods-available': '/etc/raddb/mods-available',
        }.each do |name, path|
          is_expected.to contain_file(name)
            .with_path(path)
            .with(
              'ensure'  => 'directory',
              'group'   => 'radiusd',
              'mode'    => '0755',
              'notify'  => 'Service[radiusd]',
              'owner'   => 'root',
            )
            .that_requires('Package[freeradius]')
            .that_requires('Group[radiusd]')
        end
      end

      it do
        {
          'freeradius certs': '/etc/raddb/certs',
          'freeradius clients.d': '/etc/raddb/clients.d',
          'freeradius listen.d': '/etc/raddb/listen.d',
          'freeradius sites-enabled': '/etc/raddb/sites-enabled',
          'freeradius instantiate': '/etc/raddb/instantiate',
        }.each do |name, path|
          is_expected.to contain_file(name)
            .with_path(path)
            .with(
              'ensure'  => 'directory',
              'group'   => 'radiusd',
              'mode'    => '0755',
              'notify'  => 'Service[radiusd]',
              'owner'   => 'root',
              'purge'   => 'true',
              'recurse' => 'true',
            )
            .that_requires('Package[freeradius]')
            .that_requires('Group[radiusd]')
        end
      end

      it do
        is_expected.to contain_concat('freeradius policy.conf')
          .with_path('/etc/raddb/policy.conf')
          .with(
            'group'          => 'radiusd',
            'mode'           => '0640',
            'notify'         => 'Service[radiusd]',
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('policy_header')
          .with(
            'content' => 'policy {',
            'order'   => '10',
            'target'  => 'freeradius policy.conf',
          )
      end

      it do
        is_expected.to contain_concat__fragment('policy_footer')
          .with(
            'content' => '}',
            'order'   => '99',
            'target'  => 'freeradius policy.conf',
          )
      end

      it do
        is_expected.to contain_concat('freeradius proxy.conf')
          .with_path('/etc/raddb/proxy.conf')
          .with(
            'group'          => 'radiusd',
            'mode'           => '0640',
            'notify'         => 'Service[radiusd]',
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('proxy_header')
          .with(
            'content' => '# Proxy config',
            'order'   => '05',
            'target'  => 'freeradius proxy.conf',
          )
      end

      it do
        is_expected.to contain_concat('freeradius mods-available/attr_filter')
          .with_path('/etc/raddb/mods-available/attr_filter')
          .with(
            'group'          => 'radiusd',
            'mode'           => '0640',
            'notify'         => 'Service[radiusd]',
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('attr-default')
          .with(
            'order'   => '10',
            'target'  => 'freeradius mods-available/attr_filter',
          )
      end

      it do
        is_expected.to contain_concat('freeradius dictionary')
          .with_path('/etc/raddb/dictionary')
          .with(
            'group'          => 'radiusd',
            'mode'           => '0644',
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('freeradius dictionary_header')
          .with(
            'order'  => '10',
            'source' => 'puppet:///modules/freeradius/dictionary.header',
            'target' => 'freeradius dictionary',
          )
      end

      it do
        is_expected.to contain_concat__fragment('freeradius dictionary_footer')
          .with(
            'order'  => '90',
            'source' => 'puppet:///modules/freeradius/dictionary.footer',
            'target' => 'freeradius dictionary',
          )
      end

      it do
        is_expected.to contain_package('freeradius')
          .with(
            'ensure' => 'installed',
            'name'   => 'freeradius',
          )
      end

      it do
        is_expected.to contain_service('radiusd')
          .with(
            'enable'     => 'true',
            'ensure'     => 'running',
            'hasrestart' => 'true',
            'hasstatus'  => 'true',
            'name'       => 'radiusd',
          )
          .that_requires('Package[freeradius]')
          .that_requires('User[radiusd]')
          .that_requires('Exec[radiusd-config-test]')
          .that_requires('File[freeradius radiusd.conf]')
      end

      it do
        is_expected.to contain_user('radiusd')
          .with(
            'ensure'  => 'present',
            'groups'  => nil,
          )
          .that_requires('Package[freeradius]')
      end

      context 'with winbind support' do
        let(:params) do
          {
            winbind_support: true,
          }
        end

        it do
          is_expected.to contain_user('radiusd')
            .with_name('radiusd')
            .with(
              'groups'  => 'wbpriv',
            )
        end
      end

      it do
        is_expected.to contain_group('radiusd')
          .with_name('radiusd')
          .with(
            'ensure' => 'present',
          )
          .that_requires('Package[freeradius]')
      end

      it do
        is_expected.to contain_freeradius__module('always')
          .with_preserve(true)
      end

      it do
        is_expected.to contain_freeradius__module('detail')
          .with_preserve(true)
      end

      it do
        is_expected.to contain_freeradius__module('detail.log')
          .with_preserve(true)
      end

      it do
        {
          'freeradius logdir': '/var/log/radius',
          'freeradius logdir/radacct': '/var/log/radius/radacct',
        }.each do |name, path|
          is_expected.to contain_file(name)
            .with_path(path)
            .with(
              'mode'    => '0750',
              'owner' => 'radiusd',
              'group' => 'radiusd',
            )
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('freeradius radius.log')
          .with_path('/var/log/radius/radius.log')
          .with(
            'group'   => 'radiusd',
            'owner'   => 'radiusd',
            'seltype' => 'radiusd_log_t',
          )
          .that_requires('Package[freeradius]')
          .that_requires('User[radiusd]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_logrotate__rule('radacct')
          .with(
            'compress'      => 'true',
            'create'        => 'false',
            'missingok'     => 'true',
            'path'          => '/var/log/radius/radacct/*/*.log',
            'postrotate'    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
            'rotate'        => '7',
            'rotate_every'  => 'day',
            'sharedscripts' => 'true',
          )
      end

      it do
        is_expected.to contain_logrotate__rule('checkrad')
          .with(
            'compress'      => 'true',
            'create'        => 'true',
            'missingok'     => 'true',
            'path'          => '/var/log/radius/checkrad.log',
            'postrotate'    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
            'rotate'        => '1',
            'rotate_every'  => 'week',
            'sharedscripts' => 'true',
          )
      end

      it do
        is_expected.to contain_logrotate__rule('radiusd')
          .with(
            'compress'      => 'true',
            'create'        => 'true',
            'missingok'     => 'true',
            'path'          => '/var/log/radius/radius*.log',
            'postrotate'    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
            'rotate'        => '26',
            'rotate_every'  => 'week',
            'sharedscripts' => 'true',
          )
      end

      it do
        {
          'freeradius certs/dh': '/etc/raddb/certs/dh',
          'freeradius certs/random': '/etc/raddb/certs/random',
        }.each do |name, path|
          is_expected.to contain_file(name)
            .with_path(path)
            .that_requires('Exec[freeradius dh]')
            .that_requires('Exec[freeradius random]')
        end
      end

      it do
        is_expected.to contain_exec('freeradius dh')
          .with(
            'command' => 'openssl dhparam -out /etc/raddb/certs/dh 1024',
            'creates' => '/etc/raddb/certs/dh',
            'path'    => '/usr/bin',
          )
          .that_requires('File[freeradius certs]')
      end

      it do
        is_expected.to contain_exec('freeradius random')
          .with(
            'command' => 'dd if=/dev/urandom of=/etc/raddb/certs/random count=10 >/dev/null 2>&1',
            'creates' => '/etc/raddb/certs/random',
            'path'    => '/bin',
          )
          .that_requires('File[freeradius certs]')
      end

      it do
        is_expected.to contain_exec('radiusd-config-test')
          .with(
            'command'     => 'sudo radiusd -XC | grep \'Configuration appears to be OK.\' | wc -l',
            'logoutput'   => 'on_failure',
            'path'        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
            'refreshonly' => 'true',
            'returns'     => '0',
          )
      end

      it do
        {
          'freeradius clients.conf': '/etc/raddb/clients.conf',
          'freeradius sql.conf': '/etc/raddb/sql.conf',
        }.each do |name, path|
          is_expected.to contain_file(name)
            .with_path(path)
            .with(
              'content' => '# FILE INTENTIONALLY BLANK',
              'group'   => 'radiusd',
              'mode'    => '0644',
              'notify'  => 'Service[radiusd]',
              'owner'   => 'root',
            )
            .that_requires('Package[freeradius]')
            .that_requires('Group[radiusd]')
        end
      end

      it do
        if ['rocky-8-x86_64', 'centos-8-x86_64', 'redhat-8-x86_64', 'almalinux-8-x86_64'].include? os
          is_expected.to contain_systemd__dropin_file('freeradius remove bootstrap')
            .with_ensure('present')
            .with_filename('remove_bootstrap.conf')
            .with_unit('radiusd.service')
            .with_content(%r{^ExecStartPre=$})
        else
          is_expected.not_to contain_systemd__dropin_file('freeradius remove bootstrap')
        end
      end

      context 'with mysql' do
        let(:params) do
          super().merge(
            'mysql_support' => true,
          )
        end

        it do
          is_expected.to contain_package('freeradius-mysql')
            .with_name('freeradius-mysql')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with pgsql' do
        let(:params) do
          super().merge(
            'pgsql_support' => true,
          )
        end

        it do
          is_expected.to contain_package('freeradius-postgresql')
            .with_name('freeradius-postgresql')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with perl' do
        let(:params) do
          super().merge(
            'perl_support' => true,
          )
        end

        it do
          is_expected.to contain_package('freeradius-perl')
            .with_name('freeradius-perl')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with utils' do
        let(:params) do
          super().merge(
            'utils_support' => true,
          )
        end

        it do
          is_expected.to contain_package('freeradius-utils')
            .with_name('freeradius-utils')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with ldap' do
        let(:params) do
          super().merge(
            'ldap_support' => true,
          )
        end

        it do
          is_expected.to contain_package('freeradius-ldap')
            .with_name('freeradius-ldap')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with dhcp' do
        let(:params) do
          super().merge(
            'dhcp_support' => true,
          )
        end

        it do
          is_expected.to contain_package('freeradius-dhcp')
            .with_name('freeradius-dhcp')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with krb5' do
        let(:params) do
          super().merge(
            'krb5_support' => true,
          )
        end

        it do
          is_expected.to contain_package('freeradius-krb5')
            .with_name('freeradius-krb5')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with wpa_supplicant' do
        let(:params) do
          super().merge(
            'wpa_supplicant' => true,
          )
        end

        it do
          is_expected.to contain_package('wpa_supplicant')
            .with_name('wpa_supplicant')
            .with(
              'ensure' => 'installed',
            )
        end
      end

      context 'with syslog' do
        let(:params) do
          super().merge(
            'syslog' => true,
          )
        end

        it do
          is_expected.to contain_rsyslog__snippet('12-radiusd-log')
            .with(
              'content' => %r{^if \$programname == \'radiusd\' then /var/log/radius/radius.log},
            )
        end
      end

      case os_facts[:osfamily]
      when 'Redhat'
        it do
          is_expected.to contain_exec('delete-radius-rpmnew')
            .with(
              'command' => 'find /etc/raddb -name *.rpmnew -delete',
              'onlyif'  => 'find /etc/raddb -name *.rpmnew | grep rpmnew',
              'path'    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
            )
        end

        it do
          is_expected.to contain_exec('delete-radius-rpmsave')
            .with(
              'command' => 'find /etc/raddb -name *.rpmsave -delete',
              'onlyif'  => 'find /etc/raddb -name *.rpmsave | grep rpmsave',
              'path'    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
            )
        end
      end
    end
  end
end
