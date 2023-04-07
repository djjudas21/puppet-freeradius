require 'spec_helper'

describe 'freeradius::instantiate' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) { {} }

  it do
    is_expected.to contain_file('freeradius instantiate/test')
      .with_path('/etc/raddb/instantiate/test')
      .with_content('test')
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
      .that_notifies('Service[radiusd]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
  end
end
