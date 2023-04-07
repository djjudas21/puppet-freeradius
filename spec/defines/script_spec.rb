require 'spec_helper'

describe 'freeradius::script' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      source: 'puppet:///modules/path/to/script/file',
    }
  end

  it do
    is_expected.to contain_file('freeradius scripts/test')
      .with_path('/etc/raddb/scripts/test')
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0750')
      .with_owner('root')
      .with_source('puppet:///modules/path/to/script/file')
      .that_notifies('Service[radiusd]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
      .that_requires('File[freeradius scripts]')
  end
end
