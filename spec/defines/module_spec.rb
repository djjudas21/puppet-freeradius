require 'spec_helper'

describe 'freeradius::module' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      source:  'puppet:///modules/test/path/to/module',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/mods-available/test')
      .with_content(nil)
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
      .with_source('puppet:///modules/test/path/to/module')
      .that_notifies('Service[radiusd]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
  end

  it do
    is_expected.to contain_file('/etc/raddb/mods-enabled/test')
      .with_ensure('link')
      .with_target('../mods-available/test')
  end
end
