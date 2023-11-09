require 'spec_helper'

describe 'freeradius::dictionary' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      source: 'puppet:///modules/test/path/to/dict',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/dictionary.d/dictionary.test')
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0644')
      .with_owner('root')
      .with_source('puppet:///modules/test/path/to/dict')
      .that_notifies('Service[radiusd]')
      .that_requires('File[/etc/raddb/dictionary.d]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
  end

  it do
    is_expected.to contain_concat__fragment('dictionary.test')
      .with_content(%r{^\$INCLUDE /etc/raddb/dictionary\.d/dictionary\.test$})
      .with_order('50')
      .with_target('/etc/raddb/dictionary')
      .that_requires('File[/etc/raddb/dictionary.d/dictionary.test]')
  end
end
