require 'spec_helper'

describe 'freeradius::control_socket' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      # Empty params hash by default so we can super().merge
      let(:params) { {} }

      describe 'freeradius::control_socket' do
        it do
          is_expected.to contain_freeradius__site('control-socket')
        end
      end
    end
  end
end
