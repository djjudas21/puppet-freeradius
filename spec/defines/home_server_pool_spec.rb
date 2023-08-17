require 'spec_helper'

describe 'freeradius::home_server_pool' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

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
          .with_target("#{freeradius_hash[:basepath]}/proxy.conf")
      end
    end
  end
end
