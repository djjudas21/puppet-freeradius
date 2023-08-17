require 'spec_helper'

describe 'freeradius::radsniff' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    include_context 'freeradius_with_utils'

    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          options: 'radsniff cmd "line" options',
        }
      end

      if os_facts[:osfamily].match? %r{^RedHat|Debian$}
        it do
          is_expected.to contain_service('radsniff')
            .with_ensure('running')
            .with_enable(true)
        end
      end

      case os_facts[:osfamily]
      when 'RedHat', 'Debian'
        it do
          is_expected.to contain_file(freeradius_hash[:radsniff][:envfile])
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^PIDFile=#{freeradius_hash[:radsniff][:pidfile]}$})
            .with_content(%r{^EnvironmentFile=#{freeradius_hash[:radsniff][:envfile]}$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P #{freeradius_hash[:radsniff][:pidfile]} -d #{freeradius_hash[:basepath]} \$RADSNIFF_OPTIONS$})
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
          is_expected.to contain_file('/test/env/file')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_content(%r{^PIDFile=/a/pid/file$})
            .with_content(%r{^EnvironmentFile=/test/env/file$})
            .with_content(%r{^ExecStart=/usr/bin/radsniff -P /a/pid/file -d #{freeradius_hash[:basepath]} \$RADSNIFF_OPTIONS$})
            .that_notifies('Service[radsniff]')
        end
      end
    end
  end
end
