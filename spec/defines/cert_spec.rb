require 'spec_helper'

describe 'freeradius::cert' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      context 'with type set to key' do
        let(:params) do
          {
            type: 'key',
            content: 'test data',
          }
        end

        it do
          is_expected.to contain_file("#{freeradius_hash[:basepath]}/certs/test")
            .that_notifies("Service[#{freeradius_hash[:service_name]}]")
            .that_requires("File[#{freeradius_hash[:basepath]}/certs]")
            .that_requires("Group[#{freeradius_hash[:group]}]")
            .that_requires('Package[freeradius]')
            .with_content(%r{test data})
            .with_ensure('present')
            .with_group(freeradius_hash[:group])
            .with_mode('0640')
            .with_owner('root')
            .with_show_diff('false')
            .with_source(nil)
        end
      end

      context 'with type set to cert and with source' do
        let(:params) do
          {
            type: 'cert',
            source: 'puppet:///modules/test/path/to/cert',
            content: :undef,
          }
        end

        it do
          is_expected.to contain_file("#{freeradius_hash[:basepath]}/certs/test")
            .that_notifies("Service[#{freeradius_hash[:service_name]}]")
            .that_requires("File[#{freeradius_hash[:basepath]}/certs]")
            .that_requires("Group[#{freeradius_hash[:group]}]")
            .that_requires('Package[freeradius]')
            .with_content(nil)
            .with_ensure('present')
            .with_group(freeradius_hash[:group])
            .with_mode('0644')
            .with_owner('root')
            .with_show_diff('false')
            .with_source('puppet:///modules/test/path/to/cert')
        end
      end
    end
  end
end
