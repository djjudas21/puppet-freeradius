require 'spec_helper'

describe 'freeradius::policy' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source:  'puppet:///modules/test/path/to/policy',
        }
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/policy.d/test")
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0644')
          .with_owner('root')
          .with_source('puppet:///modules/test/path/to/policy')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
      end

      it do
        is_expected.to contain_concat__fragment('policy-test')
          .with_content(%r{\s+\$INCLUDE #{freeradius_hash[:basepath]}/policy.d/test$})
          .with_order('50')
          .with_target("#{freeradius_hash[:basepath]}/policy.conf")
          .that_requires("File[#{freeradius_hash[:basepath]}/policy.d/test]")
      end
    end
  end
end
