require 'spec_helper'

describe 'freeradius::policy' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      source:  'puppet:///modules/test/path/to/policy',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/policy.d/test')
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0644')
      .with_owner('root')
      .with_source('puppet:///modules/test/path/to/policy')
      .that_notifies('Service[radiusd]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
  end

  it do
    is_expected.to contain_concat__fragment('policy-test')
      .with_content(%r{\s+\$INCLUDE /etc/raddb/policy.d/test\n})
      .with_order('50')
      .with_target('/etc/raddb/policy.conf')
      .that_requires('File[/etc/raddb/policy.d/test]')
  end
end
