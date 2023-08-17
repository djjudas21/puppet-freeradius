require 'spec_helper'

describe 'freeradius::dictionary' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'puppet:///modules/test/path/to/dict',
        }
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/dictionary.d/dictionary.test")
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0644')
          .with_owner('root')
          .with_source('puppet:///modules/test/path/to/dict')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires("File[#{freeradius_hash[:basepath]}/dictionary.d]")
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_concat__fragment('dictionary.test')
          .with_content(%r{^\$INCLUDE #{freeradius_hash[:basepath]}/dictionary\.d/dictionary\.test$})
          .with_order('50')
          .with_target("#{freeradius_hash[:basepath]}/dictionary")
          .that_requires("File[#{freeradius_hash[:basepath]}/dictionary.d/dictionary.test]")
      end
    end
  end
end
