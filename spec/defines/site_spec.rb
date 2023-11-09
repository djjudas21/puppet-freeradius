require 'spec_helper'

describe 'freeradius::site' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      source: 'puppet:///modules/path/to/site/file',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/sites-available/test')
      .with_content(nil)
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
      .with_source('puppet:///modules/path/to/site/file')
      .that_notifies('Service[radiusd]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
  end

  it do
    is_expected.to contain_file('/etc/raddb/sites-enabled/test')
      .with_ensure('link')
      .with_target('/etc/raddb/sites-available/test')
  end
end
