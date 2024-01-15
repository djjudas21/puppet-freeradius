require 'spec_helper'

describe 'freeradius::site' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'puppet:///modules/path/to/site/file',
        }
      end

      case os_facts[:os][:family]
      when 'RedHat'
        it do
          is_expected.to contain_file('freeradius site-available/test')
            .with_path('/etc/raddb/sites-available/test')
            .with_group('radiusd')
            .that_notifies('Service[radiusd]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_file('freeradius sites-enabled/test')
            .with_path('/etc/raddb/sites-enabled/test')
        end
      when 'Debian'
        it do
          is_expected.to contain_file('freeradius site-available/test')
            .with_path('/etc/freeradius/3.0/site-available/test')
            .with_group('freeradius')
            .that_notifies('Service[freeradius]')
            .that_requires('Package[freeradius]')
        end

        it do
          is_expected.to contain_file('freeradius sites-enabled/test')
            .with_path('/etc/freeradius/3.0/sites-enabled/test')
        end
      end

      it do
        is_expected.to contain_file('freeradius sites-available/test')
          .with_content(nil)
          .with_ensure('present')
          .with_mode('0640')
          .with_owner('root')
          .with_source('puppet:///modules/path/to/site/file')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_file('freeradius sites-enabled/test')
          .with_ensure('link')
          .with_target('../sites-available/test')
      end
    end
  end
end
