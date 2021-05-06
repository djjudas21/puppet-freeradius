require 'spec_helper'

describe 'freeradius::sql' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          database: 'postgresql',
          password: 'test_password',
          port: 5432,
        }
      end

      it do
        is_expected.to contain_file('/etc/raddb/mods-available/test')
          .with_content(%r{^sql test \{\n})
          .with_content(%r{^\s+dialect = "postgresql"$})
          .with_content(%r{^\s+server = "localhost"$})
          .with_content(%r{^\s+port = "5432"$})
          .with_content(%r{^\s+login = "radius"$})
          .with_content(%r{^\s+password = "test_password"$})
          .with_content(%r{^\s+postauth_table = "radpostauth"$})
          .with_ensure('present')
          .with_group('radiusd')
          .with_mode('0640')
          .with_owner('root')
          .without_content(%r{^\s+logfile =})
          .that_notifies('Service[radiusd]')
          .that_requires('Package[freeradius]')
          .that_requires('Group[radiusd]')
      end

      it do
        is_expected.to contain_file('/etc/raddb/mods-enabled/test')
          .with_ensure('link')
          .with_target('../mods-available/test')
      end

      context 'with sqltrace' do
        let(:params) do
          super().merge(
            sqltrace: 'yes',
          )
        end

        it do
          is_expected.to contain_file('/etc/raddb/mods-available/test')
            .with_content(%r{^\s+logfile = \${logdir}/sqllog.sql$})
        end

        it do
          is_expected.to contain_logrotate__rule('sqltrace')
            .with_compress('true')
            .with_create('true')
            .with_missingok('true')
            .with_path('/var/log/radius/${logdir}/sqllog.sql')
            .with_postrotate('kill -HUP `cat /var/run/radiusd/radiusd.pid`')
            .with_rotate('1')
            .with_rotate_every('week')
        end
      end

      context 'with custom query file' do
        let(:params) do
          super().merge(
            custom_query_file: 'puppet:///modules/path/to/custom/query/file',
          )
        end

        it do
          is_expected.to contain_freeradius__config('test-queries.conf')
            .with_source('puppet:///modules/path/to/custom/query/file')
        end
      end
    end
  end
end
