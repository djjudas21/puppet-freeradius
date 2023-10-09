require 'spec_helper'

describe 'freeradius::blank' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) { {} }

  it do
    is_expected.to contain_file('freeradius test')
      .with_path('/etc/raddb/test')
      .that_notifies('Service[radiusd]')
      .that_requires('File[freeradius raddb]')
      .that_requires('Group[radiusd]')
      .that_requires('Package[freeradius]')
      .with_content(%r{^# This file is intentionally left blank .*})
      .with_group('radiusd')
      .with_mode('0644')
      .with_owner('root')
  end
end
