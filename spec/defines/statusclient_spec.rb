require 'spec_helper'
require 'yaml'

describe 'freeradius::statusclient' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'
      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          secret: 'test_secret',
          ip: '1.2.3.4',
        }
      end

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius statusclients.d/test.conf')
            .with_path('/etc/raddb/statusclients.d/test.conf')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius statusclients.d/test.conf')
            .with_path('/etc/freeradius/3.0/statusclients.d/test.conf')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end
      end

      it do
        is_expected.to contain_file('freeradius statusclients.d/test.conf')
          .with_content(%r{^client test {\n\s+ipaddr = 1.2.3.4\n\s+shortname = test\n\s+secret = "test_secret"\n}\n})
          .with_ensure('present')
          .with_mode('0640')
          .with_owner('root')
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
  end
end
