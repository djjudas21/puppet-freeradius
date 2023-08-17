require 'spec_helper'

describe 'freeradius::script' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'puppet:///modules/path/to/script/file',
        }
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/scripts/test")
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0750')
          .with_owner('root')
          .with_source('puppet:///modules/path/to/script/file')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
          .that_requires("File[#{freeradius_hash[:basepath]}/scripts]")
      end
    end
  end
end
