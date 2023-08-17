require 'spec_helper'

describe 'freeradius::krb5' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

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

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/mods-available/test")
          .with_content(%r{^\s+keytab = test_keytab$})
          .with_content(%r{^\s+service_principal = test_principal$})
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0640')
          .with_owner('root')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/mods-enabled/test")
          .with_ensure('link')
          .with_target('../mods-available/test')
      end
    end
  end
end
