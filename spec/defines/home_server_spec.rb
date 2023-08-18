require 'spec_helper'

describe 'freeradius::home_server' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      secret: 'test_secret',
      ipaddr: '1.2.3.4',
    }
  end

  it do
    is_expected.to contain_concat__fragment('homeserver-test')
      .with_content(%r{home_server test {\n\s+type = auth\n\s+ipaddr = 1.2.3.4\n\s+port = 1812\n\s+proto = udp\n\s+secret = "test_secret"\n\s+status_check = none\n}\n})
      .with_order('10')
      .with_target('freeradius proxy.conf')
  end

  context 'with secret containing a newline' do
    let(:params) do
      super().merge(
        secret: "foo\nbar",
      )
    end

    it do
      is_expected.to compile.and_raise_error(%r{parameter 'secret' expects a match for Freeradius::Secret})
    end
  end

  context 'with password containing a newline' do
    let(:params) do
      super().merge(
        password: "foo\nbar",
      )
    end

    it do
      is_expected.to compile.and_raise_error(%r{parameter 'password' expects a match for Freeradius::Password})
    end
  end
end
