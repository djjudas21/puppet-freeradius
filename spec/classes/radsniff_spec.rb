require 'spec_helper'

describe 'freeradius::radsniff' do
  on_supported_os.each do |os, os_facts|
    include_context 'freeradius_with_utils'

    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          options: 'radsniff cmd "line" options',
        }
      end

      let(:pre_condition) do
        precondition = case os_facts[:osfamily]
                       when 'RedHat'
                         'class freeradius::params {
                             $fr_basepath = "/etc/raddb"
                             $fr_radsniff_pidfile = "/var/run/radiusd/radsniff.pid"
                             $fr_radsniff_envfile = "/etc/sysconfig/radsniff"
                           }
                           include freeradius::params'
                       when 'Debian'
                         'class freeradius::params {
                             $fr_basepath = "/etc/freeradius"
                             $fr_radsniff_pidfile = "/var/run/freeradius/radsniff.pid"
                             $fr_radsniff_envfile = "/etc/defaults/radsniff"
                           }
                           include freeradius::params'
                       else
                         'class freeradius::params {
                             $fr_basepath = "/etc/raddb"
                             $fr_radsniff_pidfile = "/var/run/radiusd/radsniff.pid"
                             $fr_radsniff_envfile = undef
                           }
                           include freeradius::params'
                       end

        super().push(precondition)
      end

      if os_facts[:osfamily].match? %r{^RedHat|Debian$}
        it do
          is_expected.to contain_service('radsniff')
            .with_ensure('running')
            .with_enable(true)
        end
      end

      case os_facts[:osfamily]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius radsniff envfile')
            .with_path('/etc/sysconfig/radsniff')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^PIDFile=/var/run/radiusd/radsniff.pid$})
            .with_content(%r{^EnvironmentFile=/etc/sysconfig/radsniff$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P /var/run/radiusd/radsniff.pid -d /etc/raddb \$RADSNIFF_OPTIONS$})
            .that_notifies('Service[radsniff]')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius radsniff envfile')
            .with_path('/etc/defaults/radsniff')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^PIDFile=/var/run/freeradius/radsniff.pid$})
            .with_content(%r{^EnvironmentFile=/etc/defaults/radsniff$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P /var/run/freeradius/radsniff.pid -d /etc/freeradius \$RADSNIFF_OPTIONS$})
            .that_notifies('Service[radsniff]')
        end
      else
        it do
          is_expected.to compile.and_raise_error(%r{freeradius::radsniff requires envfile to be explicitly set on this OS})
          is_expected.to compile.and_raise_error(%r{freeradius::radsniff requires pidfile to be explicitly set on this OS})
        end
      end

      context 'with envfile and pidfile set' do
        let(:params) do
          super().merge(
            envfile: '/test/env/file',
            pidfile: '/a/pid/file',
          )
        end

        unless os_facts[:osfamily].match? %r{^RedHat|Debian$}
          it do
            is_expected.to contain_service('radsniff')
              .with_ensure('running')
              .with_enable(true)
          end
        end

        it do
          is_expected.to contain_file('freeradius radsniff envfile')
            .with_path('/test/env/file')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^PIDFile=/a/pid/file$})
            .with_content(%r{^EnvironmentFile=/test/env/file$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P /a/pid/file -d .* \$RADSNIFF_OPTIONS$})
            .that_notifies('Service[radsniff]')
        end
      end
    end
  end
end
