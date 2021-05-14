require 'spec_helper'

describe 'freeradius::radsniff' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_with_utils'

      let(:facts) { os_facts }

      let(:params) do
        {
          options: 'radsniff cmd "line" options',
        }
      end

      if os_facts[:osfamily] =~ %r{^RedHat|Debian$}
        it do
          is_expected.to contain_service('radsniff')
            .with_ensure('running')
            .with_enable(true)
        end
      end

      case os_facts[:osfamily]
      when 'RedHat'
        it do
          is_expected.to contain_file('/etc/sysconfig/radsniff')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^Pidfile=/var/run/radiusd/radsniff.pid$})
            .with_content(%r{^EnvironmentFile=/etc/sysconfig/radsniff$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P /var/run/radiusd/radsniff.pid -d /etc/raddb $RADSNIFF_OPTIONS$})
            .that_notifies('Service[radsniff]')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('/etc/defaults/radsniff')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^Pidfile=/var/run/freeradius/radsniff.pid$})
            .with_content(%r{^EnvironmentFile=/etc/defaults/radsniff$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P /var/run/freeradius/radsniff.pid -d /etc/freeradius $RADSNIFF_OPTIONS$})
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

        if os_facts[:osfamily] !~ %r{^RedHat|Debian$}
          it do
            is_expected.to contain_service('radsniff')
              .with_ensure('running')
              .with_enable(true)
          end
        end

        it do
          is_expected.to contain_file('/test/env/file')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^Pidfile=/a/pid/file$})
            .with_content(%r{^EnvironmentFile=/test/env/file$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P /a/pid/file -d /etc/freeradius $RADSNIFF_OPTIONS$})
            .that_notifies('Service[radsniff]')
        end
      end
    end
  end
end
