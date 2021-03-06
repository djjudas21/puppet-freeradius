require 'spec_helper'

describe 'freeradius::client' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      shortname: 'test_short',
      secret: 'secret_value',
      ip: '1.2.3.4',
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/clients.d/test_short.conf')
      .with_content(%r{^client test_short {\n\s+ipaddr = 1.2.3.4\n\s+proto = \*\n\s+shortname = test_short\n\s+secret = "secret_value"\n\s+require_message_authenticator = no\n}\n})
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
      .that_notifies('Service[radiusd]')
      .that_requires('File[/etc/raddb/clients.d]')
      .that_requires('Group[radiusd]')
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
