require 'spec_helper'

describe 'freeradius::script' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'puppet:///modules/path/to/script/file',
        }
      end

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius scripts/test')
            .with_path('/etc/raddb/scripts/test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius scripts/test')
            .with_path('/etc/freeradius/3.0/scripts/test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('freeradius scripts/test')
          .with_ensure('present')
          .with_mode('0750')
          .with_owner('root')
          .with_source('puppet:///modules/path/to/script/file')
          .that_requires('File[freeradius scripts]')
      end
    end
  end
end
