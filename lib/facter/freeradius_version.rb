# Grab the FreeRADIUS version from the output of radiusd -v
Facter.add(:freeradius_version) do
  setcode do
    Facter::Core::Execution.exec('radiusd -v').split(/\n/)[0].match(/FreeRADIUS Version (\d\.\d\.\d)/)[1]
  end
end
