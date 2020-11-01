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

      case os_facts[:osfamily]
      when 'RedHat'
        it do
          is_expected.to contain_file('/etc/sysconfig/radsniff')
            .with_content(%r{RADSNIFF_OPTIONS="radsniff cmd \\"line\\" options"})
            .that_notifies('Service[radsniff]')
            .that_requires('Package[freeradius-utils]')
        end

        it do
          is_expected.to contain_service('radsniff')
            .with_ensure('running')
            .with_enable(true)
        end

        it do
          is_expected.to contain_systemd__unit_file('radsniff.service')
            .with_source('puppet:///modules/freeradius/radsniff.service')
            .that_notifies('Service[radsniff]')
        end
      else
        it do
          is_expected.to compile.and_raise_error(%r{radsniff only supports RedHat})
        end
      end
    end
  end
end
