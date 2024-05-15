RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end

# Set up a default freeradius instance, so we can test other classes which
# require freeradius to exist first
#
# function warning() allows us to test for warnings being raised, by
# translating it to a notify - though this is not yet working
shared_context 'freeradius_default' do
  let(:pre_condition) do
    [
      'class { freeradius: }',
      # 'function warning($message) { notify { "warning_test: ${message}": } }'
    ]
  end
end

# Same as above but enable utils
shared_context 'freeradius_with_utils' do
  let(:pre_condition) do
    [
      'class freeradius {
        $utils_support = true
      }
      include freeradius

      package { "freeradius-utils": }',
    ]
  end
end
