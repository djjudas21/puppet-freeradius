# Grab the FreeRADIUS version from the output of radiusd -v

# Set path to binary for our platform
dist = Facter.value(:osfamily)
case dist
when /RedHat/
  binary = 'radiusd'
when /Debian/
  binary = 'freeradius'
else
  binary = 'radiusd'
end

# Execute call to fetch version info
version = Facter::Core::Execution.exec("#{binary} -v")

# Extract full version number
Facter.add(:freeradius_version) do
  setcode do
    if !version.nil?
      minver = version.split(/\n/)[0].match(/FreeRADIUS Version (\d+\.\d+\.\d+)/)[1].to_s
    end
    minver
  end
end

# Extract major version number
Facter.add(:freeradius_maj_version) do
  setcode do
    if !version.nil?
      majver = version.split(/\n/)[0].match(/FreeRADIUS Version (\d+)\.\d+\.\d+/)[1].to_s
    end
    majver
  end
end
