require 'spec_helper'

describe 'freeradius::module::ippool' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      range_start: '192.168.0.1',
      range_stop: '192.168.0.10',
      netmask: '255.255.255.0',
    }
  end

  it do
    is_expected.to contain_freeradius__module('ippool_test')
      .with_content(%r{^\s+range_start = 192.168.0.1$})
      .with_content(%r{^\s+range_stop = 192.168.0.10$})
      .with_content(%r{^\s+netmask = 255.255.255.0$})
      .with_content(%r{^\s+cache_size = 10$})
  end
end
