require 'spec_helper'

describe 'freeradius::attr' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      source: 'puppet:///modules/test/path/to/file',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/mods-config/attr_filter/test')
      .that_notifies('Service[radiusd]')
      .that_requires('Group[radiusd]')
      .that_requires('Package[freeradius]')
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
      .with_source('puppet:///modules/test/path/to/file')
  end

  it do
    is_expected.to contain_concat__fragment('attr-test')
      .with_content(%r{^attr_filter filter.test {\n\s+key = "\%{User-Name}"\n\s+filename = \${modconfdir}/\${\.:name}/test\n}})
      .with_order('20')
      .with_target('/etc/raddb/mods-available/attr_filter')
  end
end
