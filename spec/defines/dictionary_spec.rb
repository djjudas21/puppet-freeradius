require 'spec_helper'

describe 'freeradius::dictionary' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'puppet:///modules/test/path/to/dict',
        }
      end

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius dictionary.d/dictionary.test')
            .with_path('/etc/raddb/dictionary.d/dictionary.test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_concat__fragment('dictionary.test')
            .with_content(%r{^\$INCLUDE /etc/raddb/dictionary\.d/dictionary\.test$})
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius dictionary.d/dictionary.test')
            .with_path('/etc/freeradius/3.0/dictionary.d/dictionary.test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_concat__fragment('dictionary.test')
            .with_content(%r{^\$INCLUDE /etc/freeradius/3.0/dictionary\.d/dictionary\.test$})
        end
      end

      it do
        is_expected.to contain_file('freeradius dictionary.d/dictionary.test')
          .with_ensure('present')
          .with_mode('0644')
          .with_owner('root')
          .with_source('puppet:///modules/test/path/to/dict')
          .that_requires('File[freeradius dictionary.d]')
      end

      it do
        is_expected.to contain_concat__fragment('dictionary.test')
          .with_order('50')
          .with_target('freeradius dictionary')
          .that_requires('File[freeradius dictionary.d/dictionary.test]')
      end
    end
  end
end
