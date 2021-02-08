require 'spec_helper'

describe 'freeradius::krb5' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      keytab: 'test_keytab',
      principal: 'test_principal',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/mods-available/test')
      .with_content(%r{^krb5 test \{\n\s+keytab = test_keytab\n\s+service_principal = test_principal\n})
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
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
