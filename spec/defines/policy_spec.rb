require 'spec_helper'

describe 'freeradius::policy' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source:  'puppet:///modules/test/path/to/policy',
        }
      end

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius policy.d/test')
            .with_path('/etc/raddb/policy.d/test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_concat__fragment('freeradius policy-test')
            .with_content(%r{\s+\$INCLUDE /etc/raddb/policy.d/test$})
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius policy.d/test')
            .with_path('/etc/freeradius/3.0/policy.d/test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_concat__fragment('freeradius policy-test')
            .with_content(%r{\s+\$INCLUDE /etc/freeradius/3\.0/policy.d/test$})
        end
      end

      it do
        is_expected.to contain_file('freeradius policy.d/test')
          .with_ensure('present')
          .with_mode('0644')
          .with_owner('root')
          .with_source('puppet:///modules/test/path/to/policy')
      end

      it do
        is_expected.to contain_concat__fragment('freeradius policy-test')
          .with_order('50')
          .with_target('freeradius policy.conf')
          .that_requires('File[freeradius policy.d/test]')
      end
    end
  end
end
