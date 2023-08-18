# frozen_string_literal: true

require 'spec_helper'

describe 'freeradius::template' do
  include PuppetlabsSpec::Files

  # let(:modulepath) { tmpdir("modulepath") }
  # let(:environment) { Puppet::Node::Environment.create(:testing, [modulepath]) }
  # let(:mymod) { File.join(modulepath, "mymod") }
  # let(:mymod_files) { File.join(mymod, "files") }
  # let(:mymod_a_file) { File.join(mymod_files, "some.txt") }
  # let(:mymod_templates) { File.join(mymod, "templates") }
  # let(:mymod_a_template) { File.join(mymod_templates, "some.erb") }
  # let(:mymod_manifests) { File.join(mymod, "manifests") }
  # let(:mymod_init_manifest) { File.join(mymod_manifests, "init.pp") }
  # let(:mymod_another_manifest) { File.join(mymod_manifests, "another.pp") }

  # before do
  #   FileUtils.mkdir_p(mymod_files)
  #   File.open(mymod_a_file, 'w') do |f|
  #     f.puts('something')
  #   end
  #   FileUtils.mkdir_p(mymod_templates)
  #   File.open(mymod_a_template, 'w') do |f|
  #     f.puts('<%= "something" %>')
  #   end
  #   FileUtils.mkdir_p(mymod_manifests)
  #   File.open(mymod_init_manifest, 'w') do |f|
  #     f.puts('class mymod { }')
  #   end
  #   File.open(mymod_another_manifest, 'w') do |f|
  #     f.puts('class mymod::another { }')
  #   end
  # end

  it {
    is_expected.to run
      .with_params('3.0.23', 'attr.erb')
      .and_return(4)
  }
  # it { is_expected.to run.with_params(4).and_return(8) }
  # it { is_expected.to run.with_params(nil).and_raise_error(StandardError) }
end
