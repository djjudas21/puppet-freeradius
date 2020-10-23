require 'spec_helper'

describe 'freeradius::status_server' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'redhat_params'
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      # Empty params hash by default so we can super().merge
      let(:params) { {} }

      describe 'freeradius::status_server' do
        it do
          is_expected.to contain_freeradius__site('status')
        end
      end
    end
  end
end
