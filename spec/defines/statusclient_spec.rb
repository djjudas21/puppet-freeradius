require 'spec_helper'

describe 'freeradius::statusclient' do
  include_context 'redhat_common_dependencies'

  let(:title) { 'test' }

  let(:params) do
    {
      secret: 'test_secret',
      ip: '1.2.3.4',
    }
  end

  it do
    is_expected.to contain_file('freeradius statusclients.d/test.conf')
      .with_path('/etc/raddb/statusclients.d/test.conf')
      .with_content(%r{^client test {\n\s+ipaddr = 1.2.3.4\n\s+shortname = test\n\s+secret = "test_secret"\n}\n})
      .with_ensure('present')
      .with_group('radiusd')
      .with_mode('0640')
      .with_owner('root')
      .that_notifies('Service[radiusd]')
      .that_requires('Package[freeradius]')
      .that_requires('Group[radiusd]')
      .that_requires('File[freeradius clients.d]')
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
end
