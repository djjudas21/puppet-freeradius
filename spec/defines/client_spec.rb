require 'spec_helper'

describe 'freeradius::client' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          shortname: 'test_short',
          secret: 'secret_value',
          ip: '1.2.3.4',
        }
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/clients.d/test.conf")
          .with_content(%r{^client test_short {\n\s+ipaddr = 1.2.3.4\n\s+proto = \*\n\s+shortname = test_short\n\s+secret = "secret_value"\n\s+require_message_authenticator = no\n}\n})
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0640')
          .with_owner('root')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires("File[#{freeradius_hash[:basepath]}/clients.d]")
          .that_requires("Group[#{freeradius_hash[:group]}]")
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

      context 'with password' do
        let(:params) do
          super().merge(
            password: 'foo bar',
          )
        end

        it do
          is_expected.to contain_file("#{freeradius_hash[:basepath]}/clients.d/test.conf")
            .with_content(%r{^\s+password = "foo bar"$})
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
            is_expected.to contain_firewall('100 test 1234 v4')
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
              is_expected.not_to contain_firewall('100 test 1234 v4')

              is_expected.to contain_firewall('100 test 1234 v6')
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
            is_expected.to contain_firewall('100 test 1234,4321 v4')
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
              is_expected.not_to contain_firewall('100 test 1234,4321 v4')

              is_expected.to contain_firewall('100 test 1234,4321 v6')
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
  end
end
