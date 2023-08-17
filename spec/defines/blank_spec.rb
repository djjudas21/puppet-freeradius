require 'spec_helper'

describe 'freeradius::blank' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) { {} }

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/test")
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires("File[#{freeradius_hash[:basepath]}]")
          .that_requires("Group[#{freeradius_hash[:group]}]")
          .that_requires('Package[freeradius]')
          .with_content(%r{^# This file is intentionally left blank .*})
          .with_group(freeradius_hash[:group])
          .with_mode('0644')
          .with_owner('root')
      end
    end
  end
end
