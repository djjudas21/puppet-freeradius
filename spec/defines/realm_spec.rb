require 'spec_helper'

describe 'freeradius::realm' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      pool: 'test_pool',
      virtual_server: 'test_virtual_server',
    }
  end

  it do
    is_expected.to contain_concat__fragment('realm-test')
      .with_content(%r{^realm test {\n\s+virtual_server = test_virtual_server\n\s+pool = test_pool\n}})
      .with_order('30')
      .with_target('/etc/raddb/proxy.conf')
  end
end
