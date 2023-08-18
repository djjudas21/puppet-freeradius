Puppet::Functions.create_function(:"freeradius::template") do
  dispatch :template do
    param 'String', :version
    param 'String', :template_name
    return_type 'String'
  end


  def template(version, template_name)
    scope = closure_scope
    environment = closure_scope.environment

    # Try get some useful bits from the version string
    begin
      (major,minor,patch) = version.match(%r{^\d+(\.\d+)?(\.\d+)?})[0].split('.')
    rescue => exception
      raise Puppet::ParseError, "freeradius::template: Unable to parse a version from #{version}"
    end

    # Build up some candidate path strings - this can be done in a nice loop, but, keeping it like this so we can insert other path formats later without untangling it
    major_path = "freeradius/" + major                                                       # freeradius/3
    minor_path = ( minor.nil? ? nil : major_path + "/" + major + "." + minor )               # freeradius/3/3.0
    patch_path = ( patch.nil? ? nil : minor_path + "/" + major + "." + minor + "." + patch ) # freeradius/3/3.0/3.0.23

    # Strip out nils, and turn the above dir strings in to a puppet template path (i.e. $module$/template/file/name.ext)
    template_paths = [ patch_path, minor_path, major_path ].reject {|path| path.nil?}.collect {|path| path + "/" + template_name}

    # Filter out the template paths - including them only if they are findable
    usable_template_paths = template_paths.select { |template_path| Puppet::Parser::Files.find_template(template_path, environment) }

    # If we found no usable template paths, raise an error
    if usable_template_paths.empty?
      raise Puppet::ParseError, "freeradius::template: No match found for #{template_name} in #{template_paths} for #{environment.to_s}"
    end

    # Choose the first template in the list
    template_path = usable_template_paths.first

    # Create a template wrapper, and render the template
    wrapper = Puppet::Parser::TemplateWrapper.new(self)
    wrapper.file = template_path

    begin
      contents = wrapper.result
    rescue => exception
      raise Puppet::ParseError, "freeradius::template: Failed to parse template #{template_path}: #{exception}"
    end

    # Return the template result
    contents
  end
end
