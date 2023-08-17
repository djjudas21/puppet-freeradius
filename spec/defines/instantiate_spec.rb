require 'spec_helper'

describe 'freeradius::instantiate' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) { {} }

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/instantiate/test")
          .with_content('test')
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0640')
          .with_owner('root')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end
    end
  end
end
