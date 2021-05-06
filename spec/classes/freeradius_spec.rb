require 'spec_helper'

describe 'freeradius' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'redhat_params'

      let(:facts) { os_facts }

      # Empty params hash by default so we can super().merge
      let(:params) { {} }

      it do
        is_expected.to contain_file('radiusd.conf')
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
        [
          '/etc/raddb/statusclients.d',
          '/etc/raddb',
          '/etc/raddb/conf.d',
          '/etc/raddb/attr.d',
          '/etc/raddb/users.d',
          '/etc/raddb/policy.d',
          '/etc/raddb/dictionary.d',
          '/etc/raddb/scripts',
          '/etc/raddb/mods-config',
          '/etc/raddb/mods-config/attr_filter',
          '/etc/raddb/mods-config/preprocess',
          '/etc/raddb/mods-config/sql',
          '/etc/raddb/sites-available',
          '/etc/raddb/mods-available',
        ].each do |file|
          is_expected.to contain_file(file)
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
        [
          '/etc/raddb/certs',
          '/etc/raddb/clients.d',
          '/etc/raddb/listen.d',
          '/etc/raddb/sites-enabled',
          '/etc/raddb/instantiate',
        ].each do |file|
          is_expected.to contain_file(file)
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
        is_expected.to contain_concat('/etc/raddb/policy.conf')
          .with(
            'group'   => 'radiusd',
            'mode'    => '0640',
            'notify'  => 'Service[radiusd]',
            'owner'   => 'root',
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('policy_header')
          .with(
            'content' => 'policy {',
            'order'   => '10',
            'target'  => '/etc/raddb/policy.conf',
          )
      end

      it do
        is_expected.to contain_concat__fragment('policy_footer')
          .with(
            'content' => '}',
            'order'   => '99',
            'target'  => '/etc/raddb/policy.conf',
          )
      end

      it do
        is_expected.to contain_concat('/etc/raddb/proxy.conf')
          .with(
            'group'   => 'radiusd',
            'mode'    => '0640',
            'notify'  => 'Service[radiusd]',
            'owner'   => 'root',
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('proxy_header')
          .with(
            'content' => "# Proxy config\n",
            'order'   => '05',
            'target'  => '/etc/raddb/proxy.conf',
          )
      end

      it do
        is_expected.to contain_concat('/etc/raddb/mods-available/attr_filter')
          .with(
            'group'   => 'radiusd',
            'mode'    => '0640',
            'notify'  => 'Service[radiusd]',
            'owner'   => 'root',
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('attr-default')
          .with(
            'order'   => '10',
            'target'  => '/etc/raddb/mods-available/attr_filter',
          )
      end

      it do
        is_expected.to contain_concat('/etc/raddb/dictionary')
          .with(
            'group'   => 'radiusd',
            'mode'    => '0640',
            'owner'   => 'root',
          )
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_concat__fragment('dictionary_header')
          .with(
            'order'  => '10',
            'source' => 'puppet:///modules/freeradius/dictionary.header',
            'target' => '/etc/raddb/dictionary',
          )
      end

      it do
        is_expected.to contain_concat__fragment('dictionary_footer')
          .with(
            'order'  => '90',
            'source' => 'puppet:///modules/freeradius/dictionary.footer',
            'target' => '/etc/raddb/dictionary',
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
          .that_requires('File[radiusd.conf]')
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
            .with(
              'groups'  => 'wbpriv',
            )
        end
      end

      it do
        is_expected.to contain_group('radiusd')
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
        [
          '/var/log/radius',
          '/var/log/radius/radacct',
        ].each do |file|
          is_expected.to contain_file(file)
            .with(
              'mode'    => '0750',
              'owner' => 'radiusd',
              'group' => 'radiusd',
            )
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('/var/log/radius/radius.log')
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
        [
          '/etc/raddb/certs/dh',
          '/etc/raddb/certs/random',
        ].each do |file|
          is_expected.to contain_file(file)
            .that_requires('Exec[dh]')
            .that_requires('Exec[random]')
        end
      end

      it do
        is_expected.to contain_exec('dh')
          .with(
            'command' => 'openssl dhparam -out /etc/raddb/certs/dh 1024',
            'creates' => '/etc/raddb/certs/dh',
            'path'    => '/usr/bin',
          )
          .that_requires('File[/etc/raddb/certs]')
      end

      it do
        is_expected.to contain_exec('random')
          .with(
            'command' => 'dd if=/dev/urandom of=/etc/raddb/certs/random count=10 >/dev/null 2>&1',
            'creates' => '/etc/raddb/certs/random',
            'path'    => '/bin',
          )
          .that_requires('File[/etc/raddb/certs]')
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
        [
          '/etc/raddb/clients.conf',
          '/etc/raddb/sql.conf',
        ].each do |file|
          is_expected.to contain_file(file)
            .with(
              'content' => "# FILE INTENTIONALLY BLANK\n",
              'group'   => 'radiusd',
              'mode'    => '0644',
              'notify'  => 'Service[radiusd]',
              'owner'   => 'root',
            )
            .that_requires('Package[freeradius]')
            .that_requires('Group[radiusd]')
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
            .with(
              'ensure' => 'installed',
              'name'   => 'wpa_supplicant',
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
