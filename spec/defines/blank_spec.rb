require 'spec_helper'

describe 'freeradius::blank' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) { {} }

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius test')
            .with_path('/etc/raddb/test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius test')
            .with_path('/etc/freeradius/3.0/test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('freeradius test')
          .that_requires('File[freeradius raddb]')
          .with_content(%r{^# This file is intentionally left blank .*})
          .with_mode('0644')
          .with_owner('root')
      end
    end
  end
end
