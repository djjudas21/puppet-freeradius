require 'spec_helper'

describe 'freeradius::statusclient' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

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

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/statusclients.d/test.conf")
          .with_content(%r{^client test {\n\s+ipaddr = 1.2.3.4\n\s+shortname = test\n\s+secret = "test_secret"\n}\n})
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0640')
          .with_owner('root')
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires('Package[freeradius]')
          .that_requires("Group[#{freeradius_hash[:group]}]")
          .that_requires("File[#{freeradius_hash[:basepath]}/clients.d]")
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
