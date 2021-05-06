require 'spec_helper'

describe 'freeradius::ldap' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      identity: 'cn=root,dc=example,dc=com',
      password: 'test password',
      basedn: 'dc=example,dc=com',
      server: ['localhost'],
    }
  end

  let(:facts) do
    {
      freeradius_version: '3.0.21',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/mods-available/test')
      .with_content(%r{^ldap test \{\n})
      .with_content(%r{^\s+server = 'localhost'\n})
      .with_content(%r{^\s+identity = 'cn=root,dc=example,dc=com'\n})
      .with_content(%r{^\s+password = 'test password'\n})
      .with_content(%r{^\s+base_dn = 'dc=example,dc=com'\n})
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
