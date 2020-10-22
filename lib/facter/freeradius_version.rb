# Grab the FreeRADIUS version from the output of radiusd -v

module Facter::Util::FreeradiusVersion
  class << self
    def version_string
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

      Facter::Core::Execution.exec("#{binary} -v")
    end
  end
end

# Extract full version number
Facter.add(:freeradius_version) do
  setcode do
    version_string = Facter::Util::FreeradiusVersion.version_string
    if !version_string.nil?
      version = version_string.split(/\n/)[0].match(/FreeRADIUS Version (\d+\.\d+\.\d+)/)[1].to_s
    end
    version
  end
end

# Extract major version number
Facter.add(:freeradius_maj_version) do
  setcode do
    version_string = Facter::Util::FreeradiusVersion.version_string
    if !version_string.nil?
      majver = version_string.split(/\n/)[0].match(/FreeRADIUS Version (\d+)\.\d+\.\d+/)[1].to_s
    end
    majver
  end
end
