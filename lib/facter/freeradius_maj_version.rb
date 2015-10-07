# Grab the FreeRADIUS version from the output of radiusd -v
if %x{which radiusd 2>/dev/null | wc -l}.chomp.to_i > 0
  Facter.add(:freeradius_maj_version) do
    setcode do
      Facter::Core::Execution.exec('radiusd -v').split(/\n/)[0].match(/FreeRADIUS Version (\d)\.\d\.\d/)[1]
    end
  end
end

