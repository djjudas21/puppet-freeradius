# Grab the FreeRADIUS version from the output of radiusd -v
Facter.add(:freeradius_maj_version) do
  setcode do
    version = Facter::Core::Execution.exec('radiusd -v')
    if version.nil?
      version = Facter::Core::Execution.exec('freeradius -v')
    end
    if !version.nil?
      version = version.split(/\n/)[0].match(/FreeRADIUS Version (\d)\.\d\.\d/)[1].to_s
    end
    version
  end
end
