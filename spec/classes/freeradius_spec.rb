require 'spec_helper'

describe 'freeradius' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      # Empty params hash by default so we can super().merge
      let(:params) { {} }

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius radiusd.conf')
            .with_path('/etc/raddb/radiusd.conf')
            .with_group('radiusd')
        end

        it do
          {
            'freeradius statusclients.d': '/etc/raddb/statusclients.d',
            'freeradius raddb': '/etc/raddb/raddb',
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
            'freeradius certs': '/etc/raddb/certs',
            'freeradius clients.d': '/etc/raddb/clients.d',
            'freeradius listen.d': '/etc/raddb/listen.d',
            'freeradius sites-enabled': '/etc/raddb/sites-enabled',
            'freeradius instantiate': '/etc/raddb/instantiate',
            'freeradius clients.conf': '/etc/raddb/clients.conf',
            'freeradius sql.conf': '/etc/raddb/sql.conf',
          }.each do |name, path|
            is_expected.to contain_file(name)
              .with_path(path)
              .with_group('radiusd')
          end
        end

        it do
          is_expected.to contain_concat('freeradius policy.conf')
            .with_path('/etc/raddb/policy.conf')
            .with_group('radiusd')
        end

        it do
          is_expected.to contain_concat('freeradius proxy.conf')
            .with_path('/etc/raddb/proxy.conf')
            .with_group('radiusd')
        end

        it do
          is_expected.to contain_concat('freeradius mods-available/attr_filter')
            .with_path('/etc/raddb/mods-available/attr_filter')
            .with_group('radiusd')
        end

        it do
          is_expected.to contain_concat('freeradius dictionary')
            .with_path('/etc/raddb/dictionary')
            .with_group('radiusd')
        end

        it do
          is_expected.to contain_service('radiusd')
            .with_name('radiusd')
        end

        it do
          is_expected.to contain_user('radiusd')
            .with_name('radiusd')
        end

        it do
          is_expected.to contain_group('radiusd')
            .with_name('radiusd')
        end

        it do
          {
            'freeradius logdir': '/var/log/radius',
            'freeradius logdir/radacct': '/var/log/radius/radacct',
          }.each do |name, path|
            is_expected.to contain_file(name)
              .with_path(path)
              .with_owner('radiusd')
              .with_group('radiusd')
          end
        end

        it do
          is_expected.to contain_file('freeradius radius.log')
            .with_owner('radiusd')
            .with_group('radiusd')
        end

        it do
          is_expected.to contain_logrotate__rule('radacct')
            .with_path('/var/log/radius/radacct/*/*.log')
            .with_postrotate('kill -HUP `cat /var/run/radiusd/radiusd.pid`')
        end

        it do
          is_expected.to contain_logrotate__rule('checkrad')
            .with_path('/var/log/radius/checkrad.log')
            .with_postrotate('kill -HUP `cat /var/run/radiusd/radiusd.pid`')
        end

        it do
          is_expected.to contain_logrotate__rule('radiusd')
            .with_path('/var/log/radius/radius*.log')
            .with_postrotate('kill -HUP `cat /var/run/radiusd/radiusd.pid`')
        end

        it do
          is_expected.to contain_exec('freeradius dh')
            .with_command('openssl dhparam -out /etc/raddb/certs/dh 1024')
            .with_creates('/etc/raddb/certs/dh')
        end

        it do
          is_expected.to contain_exec('freeradius random')
            .with_command('dd if=/dev/urandom of=/etc/raddb/certs/random count=10 >/dev/null 2>&1')
            .with_creates('/etc/raddb/certs/random')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius radiusd.conf')
            .with_path('/etc/freeradius/3.0/radiusd.conf')
            .with_group('freeradius')
        end

        it do
          {
            'freeradius statusclients.d': '/etc/freeradius/3.0/statusclients.d',
            'freeradius raddb': '/etc/freeradius/3.0/raddb',
            'freeradius conf.d': '/etc/freeradius/3.0/conf.d',
            'freeradius attr.d': '/etc/freeradius/3.0/attr.d',
            'freeradius users.d': '/etc/freeradius/3.0/users.d',
            'freeradius policy.d': '/etc/freeradius/3.0/policy.d',
            'freeradius dictionary.d': '/etc/freeradius/3.0/dictionary.d',
            'freeradius scripts': '/etc/freeradius/3.0/scripts',
            'freeradius mods-config': '/etc/freeradius/3.0/mods-config',
            'freeradius mods-config/attr_filter': '/etc/freeradius/3.0/mods-config/attr_filter',
            'freeradius mods-config/preprocess': '/etc/freeradius/3.0/mods-config/preprocess',
            'freeradius mods-config/sql': '/etc/freeradius/3.0/mods-config/sql',
            'freeradius sites-available': '/etc/freeradius/3.0/sites-available',
            'freeradius mods-available': '/etc/freeradius/3.0/mods-available',
            'freeradius certs': '/etc/freeradius/3.0/certs',
            'freeradius clients.d': '/etc/freeradius/3.0/clients.d',
            'freeradius listen.d': '/etc/freeradius/3.0/listen.d',
            'freeradius sites-enabled': '/etc/freeradius/3.0/sites-enabled',
            'freeradius instantiate': '/etc/freeradius/3.0/instantiate',
            'freeradius clients.conf': '/etc/freeradius/3.0/clients.conf',
            'freeradius sql.conf': '/etc/freeradius/3.0/sql.conf',
          }.each do |name, path|
            is_expected.to contain_file(name)
              .with_path(path)
              .with_group('freeradius')
          end
        end

        it do
          is_expected.to contain_concat('freeradius policy.conf')
            .with_path('/etc/freeradius/3.0/policy.conf')
            .with_group('freeradius')
        end

        it do
          is_expected.to contain_concat('freeradius proxy.conf')
            .with_path('/etc/freeradius/3.0/proxy.conf')
            .with_group('freeradius')
        end

        it do
          is_expected.to contain_concat('freeradius mods-available/attr_filter')
            .with_path('/etc/freeradius/3.0/mods-available/attr_filter')
            .with_group('freeradius')
        end

        it do
          is_expected.to contain_concat('freeradius dictionary')
            .with_path('/etc/freeradius/3.0/dictionary')
            .with_group('freeradius')
        end

        it do
          is_expected.to contain_service('radiusd')
            .with_name('freeradius')
        end

        it do
          is_expected.to contain_user('radiusd')
            .with_name('freeradius')
        end

        it do
          is_expected.to contain_group('radiusd')
            .with_name('freeradius')
        end

        it do
          {
            'freeradius logdir': '/var/log/freeradius',
            'freeradius logdir/radacct': '/var/log/freeradius/radacct',
          }.each do |name, path|
            is_expected.to contain_file(name)
              .with_path(path)
              .with_owner('freeradius')
              .with_group('freeradius')
          end
        end

        it do
          is_expected.to contain_file('freeradius radius.log')
            .with_owner('freeradius')
            .with_group('freeradius')
        end

        it do
          is_expected.to contain_logrotate__rule('radacct')
            .with_path('/var/log/freeradius/radacct/*/*.log')
            .with_postrotate('kill -HUP `cat /var/run/freeradius/radiusd.pid`')
        end

        it do
          is_expected.to contain_logrotate__rule('checkrad')
            .with_path('/var/log/freeradius/checkrad.log')
            .with_postrotate('kill -HUP `cat /var/run/freeradius/radiusd.pid`')
        end

        it do
          is_expected.to contain_logrotate__rule('radiusd')
            .with_path('/var/log/freeradius/radius*.log')
            .with_postrotate('kill -HUP `cat /var/run/freeradius/radiusd.pid`')
        end

        it do
          is_expected.to contain_exec('freeradius dh')
            .with_command('openssl dhparam -out /etc/freeradius/certs/dh 1024')
            .with_creates('/etc/freeradius/certs/dh')
        end

        it do
          is_expected.to contain_exec('freeradius random')
            .with_command('dd if=/dev/urandom of=/etc/freeradius/certs/random count=10 >/dev/null 2>&1')
            .with_creates('/etc/freeradius/certs/random')
        end
      end

      it do
        is_expected.to contain_file('freeradius radiusd.conf')
          .with_mode('0644')
          .with_owner('root')
          .that_notifies('Service[radiusd]')
          .that_requires('Package[freeradius]')
      end

      it do
        [
          'freeradius statusclients.d',
          'freeradius raddb',
          'freeradius conf.d',
          'freeradius attr.d',
          'freeradius users.d',
          'freeradius policy.d',
          'freeradius dictionary.d',
          'freeradius scripts',
          'freeradius mods-config',
          'freeradius mods-config/attr_filter',
          'freeradius mods-config/preprocess',
          'freeradius mods-config/sql',
          'freeradius sites-available',
          'freeradius mods-available',
        ].each do |name|
          is_expected.to contain_file(name)
            .with_ensure('directory')
            .with_mode('0755')
            .with_owner('root')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end
      end

      it do
        [
          'freeradius certs',
          'freeradius clients.d',
          'freeradius listen.d',
          'freeradius sites-enabled',
          'freeradius instantiate',
        ].each do |name|
          is_expected.to contain_file(name)
            .with_ensure('directory')
            .with_mode('0755')
            .with_owner('root')
            .with_purge(true)
            .with_recurse(true)
        end
      end

      it do
        is_expected.to contain_concat('freeradius policy.conf')
          .with_mode('0640')
          .with_owner('root')
          .with_ensure_newline(true)
          .that_notifies('Service[radiusd]')
          .that_requires('Package[freeradius]')
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
          .with_mode('0640')
          .with_owner('root')
          .with_ensure_newline(true)
          .that_notifies('Service[radiusd]')
          .that_requires('Package[freeradius]')
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
          .with_mode('0640')
          .with_owner('root')
          .with_ensure_newline(true)
          .that_notifies('Service[radiusd]')
          .that_requires('Package[freeradius]')
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
          .with_mode('0644')
          .with_owner('root')
          .with_ensure_newline(true)
          .that_requires('Package[freeradius]')
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
          .with_enable(true)
          .with_ensure('running')
          .with_hasrestart('true')
          .with_hasstatus('true')
          .that_requires('Exec[radiusd-config-test]')
          .that_requires('File[freeradius radiusd.conf]')
          .that_requires('Package[freeradius]')
          .that_requires('User[radiusd]')
      end

      it do
        is_expected.to contain_user('radiusd')
          .with_ensure('present')
          .with_groups(nil)
          .that_requires('Package[freeradius]')
      end

      context 'with winbind support' do
        let(:params) do
          {
            winbind_support: true,
          }
        end

        case os_facts[:os][:family]
        when 'RedHat'
          it do
            is_expected.to contain_user('radiusd')
              .with_groups('wbpriv')
          end
        when 'Debian'
          it do
            is_expected.to contain_user('radiusd')
              .with_groups('winbindd_priv')
          end
        end
      end

      it do
        is_expected.to contain_group('radiusd')
          .with_ensure('present')
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
          'freeradius logdir',
          'freeradius logdir/radacct',
        ].each do |name|
          is_expected.to contain_file(name)
            .with_mode('0750')
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('freeradius radius.log')
          .with_seltype('radiusd_log_t')
          .that_requires('Package[freeradius]')
      end

      it do
        is_expected.to contain_logrotate__rule('radacct')
          .with(
            'compress'      => 'true',
            'create'        => 'false',
            'missingok'     => 'true',
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
            'rotate'        => '26',
            'rotate_every'  => 'week',
            'sharedscripts' => 'true',
          )
      end

      it do
        [
          'freeradius certs/dh',
          'freeradius certs/random',
        ].each do |name|
          is_expected.to contain_file(name)
            .that_requires('Exec[freeradius dh]')
            .that_requires('Exec[freeradius random]')
        end
      end

      it do
        is_expected.to contain_exec('freeradius dh')
          .with_path('/usr/bin')
          .that_requires('File[freeradius certs]')
      end

      it do
        is_expected.to contain_exec('freeradius random')
          .with_path('/bin')
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
        [
          'freeradius clients.conf',
          'freeradius sql.conf',
        ].each do |name|
          is_expected.to contain_file(name)
            .with_content('# FILE INTENTIONALLY BLANK')
            .with_mode('0644')
            .with_owner('root')
            .that_notifies('Service[radiusd]')
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

        case os_facts[:os][:family]
        when 'RedHat'
          it do
            is_expected.to contain_package('wpa_supplicant')
              .with_name('wpa_supplicant')
              .with_ensure('installed')
          end
        when 'Debian'
          it do
            is_expected.to contain_package('wpa_supplicant')
              .with_name('wpasupplicant')
              .with_ensure('installed')
          end
        end
      end

      context 'with syslog' do
        let(:params) do
          super().merge(
            'syslog' => true,
          )
        end

        case os_facts[:os][:family]
        when 'RedHat'
          it do
            is_expected.to contain_rsyslog__snippet('12-radiusd-log')
              .with_content(%r{^if \$programname == \'radiusd\' then /var/log/radius/radius.log})
          end
        when 'Debian'
          it do
            is_expected.to contain_rsyslog__snippet('12-radiusd-log')
              .with_content(%r{^if \$programname == \'radiusd\' then /var/log/freeradius/radius.log})
          end
        end
      end

      case os_facts[:os][:family]
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
