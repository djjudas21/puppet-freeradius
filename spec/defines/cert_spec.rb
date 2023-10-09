require 'spec_helper'

describe 'freeradius::cert' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  context 'with type set to key' do
    let(:params) do
      {
        type: 'key',
        content: 'test data',
      }
    end

    it do
      is_expected.to contain_file('freeradius certs/test')
        .with_path('/etc/raddb/certs/test')
        .that_notifies('Service[radiusd]')
        .that_requires('File[freeradius certs]')
        .that_requires('Group[radiusd]')
        .that_requires('Package[freeradius]')
        .with_content(%r{test data})
        .with_ensure('present')
        .with_group('radiusd')
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
      is_expected.to contain_file('freeradius certs/test')
        .that_notifies('Service[radiusd]')
        .that_requires('File[freeradius certs]')
        .that_requires('Group[radiusd]')
        .that_requires('Package[freeradius]')
        .with_content(nil)
        .with_ensure('present')
        .with_group('radiusd')
        .with_mode('0644')
        .with_owner('root')
        .with_show_diff('false')
        .with_source('puppet:///modules/test/path/to/cert')
    end
  end
end
