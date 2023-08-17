require 'spec_helper'

describe 'freeradius::site' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'puppet:///modules/path/to/site/file',
        }
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/sites-available/test")
          .with_content(nil)
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0640')
          .with_owner('root')
          .with_source('puppet:///modules/path/to/site/file')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/sites-enabled/test")
          .with_ensure('link')
          .with_target("#{freeradius_hash[:basepath]}/sites-available/test")
      end
    end
  end
end
