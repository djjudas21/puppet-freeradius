require 'spec_helper'

describe 'freeradius::krb5' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          keytab: 'test_keytab',
          principal: 'test_principal',
        }
      end

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius mods-available/test')
            .with_path('/etc/raddb/mods-available/test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_file('freeradius mods-enabled/test')
            .with_path('/etc/raddb/mods-enabled/test')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius mods-available/test')
            .with_path('/etc/freeradius/3.0/mods-available/test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_file('freeradius mods-enabled/test')
            .with_path('/etc/freeradius/3.0/mods-enabled/test')
        end
      end

      it do
        is_expected.to contain_file('freeradius mods-available/test')
          .with_content(%r{^\s+keytab = test_keytab$})
          .with_content(%r{^\s+service_principal = test_principal$})
          .with_ensure('present')
          .with_mode('0640')
          .with_owner('root')
      end

      it do
        is_expected.to contain_file('freeradius mods-enabled/test')
          .with_ensure('link')
          .with_target('../mods-available/test')
      end
    end
  end
end
