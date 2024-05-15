require 'spec_helper'

describe 'freeradius::cert' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius certs/test')
            .with_path('/etc/raddb/certs/test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius certs/test')
            .with_path('/etc/freeradius/3.0/certs/test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('freeradius certs/test')
          .that_requires('File[freeradius certs]')
          .with_ensure('present')
          .with_owner('root')
          .with_show_diff('false')
          .with_source(nil)
      end

      context 'with type set to key' do
        let(:params) do
          {
            type: 'key',
            content: 'test data',
          }
        end

        it do
          is_expected.to contain_file('freeradius certs/test')
            .with_content(%r{test data})
            .with_mode('0640')
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
          is_expected.to contain_file('freeradius certs/test')
            .with_content(nil)
            .with_mode('0644')
            .with_source('puppet:///modules/test/path/to/cert')
        end
      end
    end
  end
end
