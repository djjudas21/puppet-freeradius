require 'spec_helper'

describe 'freeradius::blank' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) { {} }

  it do
    is_expected.to contain_file('/etc/raddb/test')
      .that_notifies('Service[radiusd]')
      .that_requires('File[/etc/raddb]')
      .that_requires('Group[radiusd]')
      .that_requires('Package[freeradius]')
      .with_content(%r{^# This file is intentionally left blank .*})
      .with_group('radiusd')
      .with_mode('0644')
      .with_owner('root')
  end
end
