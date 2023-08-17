require 'spec_helper'

describe 'freeradius::attr' do
  on_supported_os.each do |os, os_facts|
    freeradius_hash = freeradius_settings_hash(os_facts)

    context "on #{os}" do
      include_context 'freeradius_default'

      let(:facts) { os_facts }

      let(:title) { 'test' }

      let(:params) do
        {
          source: 'puppet:///modules/test/path/to/file',
        }
      end

      it do
        is_expected.to contain_file("#{freeradius_hash[:basepath]}/mods-config/attr_filter/test")
          .that_notifies("Service[#{freeradius_hash[:service_name]}]")
          .that_requires("Group[#{freeradius_hash[:group]}]")
          .that_requires('Package[freeradius]')
          .with_ensure('present')
          .with_group(freeradius_hash[:group])
          .with_mode('0640')
          .with_owner('root')
          .with_source('puppet:///modules/test/path/to/file')
      end

      it do
        is_expected.to contain_concat__fragment('attr-test')
          .with_content(%r{^attr_filter filter.test {\n\s+key = "\%{User-Name}"\n\s+filename = \${modconfdir}/\${\.:name}/test\n}})
          .without_content(%r{^\s+relaxed\s+.*$})
          .with_order('20')
          .with_target("#{freeradius_hash[:basepath]}/mods-available/attr_filter")
      end

      context 'with relaxed = no' do
        let(:params) do
          super().merge(relaxed: 'no')
        end

        it do
          is_expected.to contain_concat__fragment('attr-test')
            .with_content(%r{^\s+relaxed\s+=\s+no$})
        end
      end

      context 'with relaxed = yes' do
        let(:params) do
          super().merge(relaxed: 'yes')
        end

        it do
          is_expected.to contain_concat__fragment('attr-test')
            .with_content(%r{^\s+relaxed\s+=\s+yes$})
        end
      end
    end
  end
end
