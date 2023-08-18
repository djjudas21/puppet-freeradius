require 'spec_helper'

describe 'freeradius::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          content: 'test content',
        }
      end

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius mods-config/test')
            .with_path('/etc/raddb/mods-config/test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius mods-config/test')
            .with_path('/etc/freeradius/3.0/mods-config/test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('freeradius mods-config/test')
          .with_content('test content')
          .with_ensure('present')
          .with_mode('0640')
          .with_owner('root')
          .with_source(nil)
      end
    end
  end
end
