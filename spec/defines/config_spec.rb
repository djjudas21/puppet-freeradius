require 'spec_helper'

describe 'freeradius::config' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      content: 'test content',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/mods-config/test')
      .with_content('test content')
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
      .with_source(nil)
      .that_notifies('Service[radiusd]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
  end
end
