require 'spec_helper'
require 'facter/freeradius_version'

describe 'freeradius_version', type: :fact do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      before :each do
        Facter.clear
        orig_facter_value_method = Facter.method(:value)
        allow(Facter).to receive(:value) do |fact|
          if facts.key?(fact)
            facts[fact]
          else
            orig_facter_value_method.call(fact)
          end
        end

        orig_exec_method = Facter::Core::Execution.method(:exec)
        allow(Facter::Core::Execution).to receive(:exec) do |cmd|
          case cmd
          when %r{^(radiusd|freeradius) -v$}
            'FreeRADIUS Version 3.0.21'
          else
            orig_exec_method.call(cmd)
          end
        end
      end

      it 'sets freeradius_version' do
        expect(Facter.fact(:freeradius_version).value).to eq('3.0.21')
      end

      it 'sets freeradius_maj_version' do
        expect(Facter.fact(:freeradius_maj_version).value).to eq('3')
      end
    end
  end
end
