require 'spec_helper'
require 'facter'

describe :freeradius_version, :type => :fact do

  before :all do
    # perform any action that should be run for the entire test suite
  end

  before :each do
    # perform any action that should be run before every test
    Facter.clear
  # This will mock the facts that confine uses to limit facts running under certain conditions
  # below is how you mock responses from the command line
  # you will need to built tests that plugin different mocked values in order to fully test your facter code
  end

  it 'should return a value' do
    expect(Facter.fact(:freeradius_version).value).to eq('value123')  #<-- change the value to match your expectation
  end
end
