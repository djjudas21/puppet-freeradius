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

  context 'with firewall' do
    let(:params) do
      super().merge(
        firewall: true,
      )
    end

    it do
      is_expected.to compile.and_raise_error(%r{Must specify \$port if you specify \$firewall})
    end

    context 'with integer port' do
      let(:params) do
        super().merge(
          port: 1234,
        )
      end

      it do
        is_expected.to contain_firewall('100 test_short 1234 v4')
          .with_proto('udp')
          .with_dport(1234)
          .with_action('accept')
          .with_source('1.2.3.4')
      end

      context 'with ipv6' do
        let(:params) do
          super().reject { |k, _| k == :ip }.merge(
            ip6: '2001:db8::100',
          )
        end

        it do
          is_expected.not_to contain_firewall('100 test_short 1234 v4')

          is_expected.to contain_firewall('100 test_short 1234 v6')
            .with_proto('udp')
            .with_dport(1234)
            .with_action('accept')
            .with_source('2001:db8::100')
            .with_provider('ip6tables')
        end
      end
    end

    context 'with array port' do
      let(:params) do
        super().merge(
          port: [1234, 4321],
        )
      end

      it do
        is_expected.to contain_firewall('100 test_short 1234,4321 v4')
          .with_proto('udp')
          .with_dport([1234, 4321])
          .with_action('accept')
          .with_source('1.2.3.4')
      end

      context 'with ipv6' do
        let(:params) do
          super().reject { |k, _| k == :ip }.merge(
            ip6: '2001:db8::100',
          )
        end

        it do
          is_expected.not_to contain_firewall('100 test_short 1234,4321 v4')

          is_expected.to contain_firewall('100 test_short 1234,4321 v6')
            .with_proto('udp')
            .with_dport([1234, 4321])
            .with_action('accept')
            .with_source('2001:db8::100')
            .with_provider('ip6tables')
        end
      end
    end
  end
end
