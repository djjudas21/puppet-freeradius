require 'spec_helper'
describe 'freeradius' do

  context 'with defaults for all parameters' do
    it { should contain_class('freeradius') }
  end
end
