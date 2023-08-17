require 'spec_helper'

describe 'freeradius' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      let(:facts) { os_facts }

      # Empty params hash by default so we can super().merge
      let(:params) { {} }

      it do
        is_expected.to contain_file('radiusd.conf')
          .with(
            'group'  => freeradius_hash[:group],
            'mode'   => '0644',
            'path'   => "#{freeradius_hash[:basepath]}/radiusd.conf",
            'notify' => "Service[#{freeradius_hash[:service_name]}]",
            'owner'  => 'root',
          )
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        [
          "#{freeradius_hash[:basepath]}/statusclients.d",
          freeradius_hash[:basepath],
          "#{freeradius_hash[:basepath]}/conf.d",
          "#{freeradius_hash[:basepath]}/attr.d",
          "#{freeradius_hash[:basepath]}/users.d",
          "#{freeradius_hash[:basepath]}/policy.d",
          "#{freeradius_hash[:basepath]}/dictionary.d",
          "#{freeradius_hash[:basepath]}/scripts",
          "#{freeradius_hash[:basepath]}/mods-config",
          "#{freeradius_hash[:basepath]}/mods-config/attr_filter",
          "#{freeradius_hash[:basepath]}/mods-config/preprocess",
          "#{freeradius_hash[:basepath]}/mods-config/sql",
          "#{freeradius_hash[:basepath]}/sites-available",
          "#{freeradius_hash[:basepath]}/mods-available",
        ].each do |file|
          is_expected.to contain_file(file)
            .with(
              'ensure'  => 'directory',
              'group'   => freeradius_hash[:group],
              'mode'    => '0755',
              'notify'  => "Service[#{freeradius_hash[:service_name]}]",
              'owner'   => 'root',
            )
            .that_requires('Package[freeradius]')
            .that_requires("Group[#{freeradius_hash[:group]}]")
        end
      end

      it do
        [
          "#{freeradius_hash[:basepath]}/certs",
          "#{freeradius_hash[:basepath]}/clients.d",
          "#{freeradius_hash[:basepath]}/listen.d",
          "#{freeradius_hash[:basepath]}/sites-enabled",
          "#{freeradius_hash[:basepath]}/instantiate",
        ].each do |file|
          is_expected.to contain_file(file)
            .with(
              'ensure'  => 'directory',
              'group'   => freeradius_hash[:group],
              'mode'    => '0755',
              'notify'  => "Service[#{freeradius_hash[:service_name]}]",
              'owner'   => 'root',
              'purge'   => 'true',
              'recurse' => 'true',
            )
            .that_requires('Package[freeradius]')
            .that_requires("Group[#{freeradius_hash[:group]}]")
        end
      end

      it do
        is_expected.to contain_concat("#{freeradius_hash[:basepath]}/policy.conf")
          .with(
            'group'          => freeradius_hash[:group],
            'mode'           => '0640',
            'notify'         => "Service[#{freeradius_hash[:service_name]}]",
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_concat__fragment('policy_header')
          .with(
            'content' => 'policy {',
            'order'   => '10',
            'target'  => "#{freeradius_hash[:basepath]}/policy.conf",
          )
      end

      it do
        is_expected.to contain_concat__fragment('policy_footer')
          .with(
            'content' => '}',
            'order'   => '99',
            'target'  => "#{freeradius_hash[:basepath]}/policy.conf",
          )
      end

      it do
        is_expected.to contain_concat("#{freeradius_hash[:basepath]}/proxy.conf")
          .with(
            'group'          => freeradius_hash[:group],
            'mode'           => '0640',
            'notify'         => "Service[#{freeradius_hash[:service_name]}]",
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_concat__fragment('proxy_header')
          .with(
            'content' => '# Proxy config',
            'order'   => '05',
            'target'  => "#{freeradius_hash[:basepath]}/proxy.conf",
          )
      end

      it do
        is_expected.to contain_concat("#{freeradius_hash[:basepath]}/mods-available/attr_filter")
          .with(
            'group'          => freeradius_hash[:group],
            'mode'           => '0640',
            'notify'         => "Service[#{freeradius_hash[:service_name]}]",
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_concat__fragment('attr-default')
          .with(
            'order'   => '10',
            'target'  => "#{freeradius_hash[:basepath]}/mods-available/attr_filter",
          )
      end

      it do
        is_expected.to contain_concat("#{freeradius_hash[:basepath]}/dictionary")
          .with(
            'group'          => freeradius_hash[:group],
            'mode'           => '0644',
            'owner'          => 'root',
            'ensure_newline' => true,
          )
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_concat__fragment('dictionary_header')
          .with(
            'order'  => '10',
            'source' => 'puppet:///modules/freeradius/dictionary.header',
            'target' => "#{freeradius_hash[:basepath]}/dictionary",
          )
      end

      it do
        is_expected.to contain_concat__fragment('dictionary_footer')
          .with(
            'order'  => '90',
            'source' => 'puppet:///modules/freeradius/dictionary.footer',
            'target' => "#{freeradius_hash[:basepath]}/dictionary",
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
        is_expected.to contain_service(freeradius_hash[:service_name])
          .with(
            'enable'     => 'true',
            'ensure'     => 'running',
            'hasrestart' => 'true',
            'hasstatus'  => 'true',
            'name'       => freeradius_hash[:service_name],
          )
          .that_requires('Package[freeradius]')
          .that_requires("User[#{freeradius_hash[:user]}]")
          .that_requires('Exec[radiusd-config-test]')
          .that_requires("File[#{freeradius_hash[:basepath]}/radiusd.conf]")
      end

      it do
        is_expected.to contain_user(freeradius_hash[:user])
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
          is_expected.to contain_user(freeradius_hash[:user])
            .with(
              'groups'  => freeradius_hash[:wbpriv_user],
            )
        end
      end

      it do
        is_expected.to contain_group(freeradius_hash[:group])
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
          freeradius_hash[:logpath],
          "#{freeradius_hash[:logpath]}/radacct",
        ].each do |file|
          is_expected.to contain_file(file)
            .with(
              'mode'  => '0750',
              'owner' => freeradius_hash[:user],
              'group' => freeradius_hash[:group],
            )
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:logpath]}/radius.log")
          .with(
            'group'   => freeradius_hash[:group],
            'owner'   => freeradius_hash[:user],
            'seltype' => 'radiusd_log_t',
          )
          .that_requires('Package[freeradius]')
          .that_requires("User[#{freeradius_hash[:user]}]")
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_logrotate__rule('radacct')
          .with(
            'compress'      => 'true',
            'create'        => 'false',
            'missingok'     => 'true',
            'path'          => "#{freeradius_hash[:logpath]}/radacct/*/*.log",
            'postrotate'    => "kill -HUP `cat /var/run/#{freeradius_hash[:service_name]}/#{freeradius_hash[:service_name]}.pid`",
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
            'path'          => "#{freeradius_hash[:logpath]}/checkrad.log",
            'postrotate'    => "kill -HUP `cat /var/run/#{freeradius_hash[:service_name]}/#{freeradius_hash[:service_name]}.pid`",
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
            'path'          => "#{freeradius_hash[:logpath]}/radius*.log",
            'postrotate'    => "kill -HUP `cat /var/run/#{freeradius_hash[:service_name]}/#{freeradius_hash[:service_name]}.pid`",
            'rotate'        => '26',
            'rotate_every'  => 'week',
            'sharedscripts' => 'true',
          )
      end

      it do
        [
          "#{freeradius_hash[:basepath]}/certs/dh",
          "#{freeradius_hash[:basepath]}/certs/random",
        ].each do |file|
          is_expected.to contain_file(file)
            .that_requires('Exec[dh]')
            .that_requires('Exec[random]')
        end
      end

      it do
        is_expected.to contain_exec('dh')
          .with(
            'command' => "openssl dhparam -out #{freeradius_hash[:basepath]}/certs/dh 1024",
            'creates' => "#{freeradius_hash[:basepath]}/certs/dh",
            'path'    => '/usr/bin',
          )
          .that_requires("File[#{freeradius_hash[:basepath]}/certs]")
      end

      it do
        is_expected.to contain_exec('random')
          .with(
            'command' => "dd if=/dev/urandom of=#{freeradius_hash[:basepath]}/certs/random count=10 >/dev/null 2>&1",
            'creates' => "#{freeradius_hash[:basepath]}/certs/random",
            'path'    => '/bin',
          )
          .that_requires("File[#{freeradius_hash[:basepath]}/certs]")
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
          "#{freeradius_hash[:basepath]}/clients.conf",
          "#{freeradius_hash[:basepath]}/sql.conf",
        ].each do |file|
          is_expected.to contain_file(file)
            .with(
              'content' => '# FILE INTENTIONALLY BLANK',
              'group'   => freeradius_hash[:group],
              'mode'    => '0644',
              'notify'  => "Service[#{freeradius_hash[:service_name]}]",
              'owner'   => 'root',
            )
            .that_requires('Package[freeradius]')
            .that_requires("Group[#{freeradius_hash[:group]}]")
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
              'name'   => freeradius_hash[:wpa_supplicant_package_name],
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
              'content' => %r{^if \$programname == \'radiusd\' then #{freeradius_hash[:logpath]}/radius.log},
            )
        end
      end

      case os_facts[:osfamily]
      when 'Redhat'
        it do
          is_expected.to contain_exec('delete-radius-rpmnew')
            .with(
              'command' => "find #{freeradius_hash[:basepath]} -name *.rpmnew -delete",
              'onlyif'  => "find #{freeradius_hash[:basepath]} -name *.rpmnew | grep rpmnew",
              'path'    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
            )
        end

        it do
          is_expected.to contain_exec('delete-radius-rpmsave')
            .with(
              'command' => "find #{freeradius_hash[:basepath]} -name *.rpmsave -delete",
              'onlyif'  => "find #{freeradius_hash[:basepath]} -name *.rpmsave | grep rpmsave",
              'path'    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
            )
        end
      end
    end
  end
end
