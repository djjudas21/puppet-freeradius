source "https://rubygems.org"

group :test do
    gem "rake"
    gem "puppet", ENV['PUPPET_GEM_VERSION'] || '~> 3.8.3'
    gem "rspec-puppet"
    gem "puppetlabs_spec_helper"
    gem 'rspec-puppet-utils'
    gem 'hiera-puppet-helper', :git => 'https://github.com/bobtfish/hiera-puppet-helper.git'
    gem "metadata-json-lint"
    gem 'puppet-syntax'
    gem 'puppet-lint'
end

# to disable installing the 50+ gems this group contains run : bundle install --without integration
group :integration do
    gem "beaker"
    gem "beaker-rspec"
    gem "vagrant-wrapper"
    gem 'serverspec'
end

group :development do
    gem "travis"
    gem "travis-lint"
    gem "puppet-blacksmith"
    gem 'puppet-debugger'
# This gem causes bundler install erorrs
#    gem "guard-rake"
end
