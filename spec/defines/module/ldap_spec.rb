require 'spec_helper'

describe 'freeradius::module::ldap' do
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

  let(:node_params) do
    {
      'freeradius::fr_3_1' => false,
    }
  end

  it do
    is_expected.to contain_file('/etc/raddb/mods-available/test')
      .with_content(%r{^ldap test \{\n})
      .with_content(%r{^\s+server = 'localhost'\n})
      .with_content(%r{^\s+identity = 'cn=root,dc=example,dc=com'\n})
      .with_content(%r{^\s+password = 'test password'\n})
      .with_content(%r{^\s+base_dn = 'dc=example,dc=com'\n})
      .with_content(%r{^\s+update \{\n})
      .without_content(%r{^\s+connect_timeout = .*})
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

  context 'when freeradius::fr_3_1 is true' do
    let(:facts) do
      super().merge(
        'freeradius_version' => '3.1.1',
      )
    end

    let(:node_params) do
      {
        'freeradius::fr_3_1' => true,
      }
    end

    it do
      is_expected.to contain_file('/etc/raddb/mods-available/test')
        .with_content(%r{^\s+connect_timeout = 3.0})
        .with_content(%r{^\s+use_referral_credentials = no})
        .without_content(%r{^\s+session_tracking = .*})
    end

    context 'with connect_timeout, session_tracking, and use_referral_credentials specified' do
      let(:params) do
        super().merge(
          connect_timeout: 5.0,
          session_tracking: 'yes',
          use_referral_credentials: 'yes',
        )
      end

      it do
        is_expected.to contain_file('/etc/raddb/mods-available/test')
          .with_content(%r{^\s+connect_timeout = 5.0})
          .with_content(%r{^\s+use_referral_credentials = yes})
          .with_content(%r{^\s+session_tracking = yes})
      end

      # it do
      #   is_expected.to create_notify('warning_test').with_message(%r{^The `connect_timeout` parameter requires FreeRADIUS 3.1.x})
      # end

      # it do
      #   is_expected.to create_notify('warning_test').with_message(%r{^The `use_referral_credentials` parameter requires FreeRADIUS 3.1.x})
      # end

      # it do
      #   is_expected.to create_notify('warning_test').with_message(%r{^The `session_tracking` parameter requires FreeRADIUS 3.1.x})
      # end
    end
  end

  # context 'with connect_timeout specified' do
  #   let(:params) do
  #     super().merge(
  #       connect_timeout: 5.0,
  #     )
  #   end

  #   it do
  #     is_expected.to compile.and_raise_error(%r{^The \`connect_timeout` parameter requires FreeRADIUS 3\.1\.x})
  #   end
  # end

  # context 'with session_tracking specified' do
  #   let(:params) do
  #     super().merge(
  #       session_tracking: 'yes',
  #     )
  #   end

  #   it do
  #     is_expected.to compile.and_raise_error(%r{^The `session_tracking` parameter requires FreeRADIUS 3.1.x})
  #   end
  # end

  # context 'with use_referral_credentials specified' do
  #   let(:params) do
  #     super().merge(
  #       use_referral_credentials: 'yes',
  #     )
  #   end

  #   it do
  #     is_expected.to compile.and_raise_error(%r{^The `use_referral_credentials` parameter requires FreeRADIUS 3.1.x})
  #   end
  # end

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

  context 'with update passed' do
    let(:params) do
      super().merge(
        update: [
          "reply:Framed-IP-Address := 'radiusFramedIPAddress'",
          "control:Password-With-Header	+= 'userPassword'",
        ],
      )
    end

    it do
      is_expected.to contain_file('/etc/raddb/mods-available/test')
        .with_content(%r{^\s+update \{\n\s+control:Password-With-Header	\+= 'userPassword'\n\s+reply:Framed-IP-Address := 'radiusFramedIPAddress'\n\s+\}\n})
    end
  end
end
