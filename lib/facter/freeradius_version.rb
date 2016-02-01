# Grab the FreeRADIUS version from the output of radiusd -v
version = Facter::Core::Execution.exec('radiusd -v')
if version.nil?
  version = Facter::Core::Execution.exec('freeradius -v')
end

Facter.add(:freeradius_version) do
  setcode do
    if !version.nil?
      minver = version.split(/\n/)[0].match(/FreeRADIUS Version (\d\.\d\.\d)/)[1].to_s
    end
    minver
  end
end

Facter.add(:freeradius_maj_version) do
  setcode do
    if !version.nil?
      majver = version.split(/\n/)[0].match(/FreeRADIUS Version (\d)\.\d\.\d/)[1].to_s
    end
    majver
  end
end
