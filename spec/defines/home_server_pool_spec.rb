require 'spec_helper'

describe 'freeradius::home_server_pool' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      home_server: [
        'test_home_server_1',
        'test_home_server_2',
      ],
    }
  end

  it do
    is_expected.to contain_concat__fragment('homeserverpool-test')
      .with_content(%r{home_server_pool test {\n\s+type = fail-over\n\s+home_server = test_home_server_1\n\s+home_server = test_home_server_2\n}\n})
      .with_order('20')
      .with_target('/etc/raddb/proxy.conf')
  end
end
