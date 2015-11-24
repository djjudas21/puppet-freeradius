# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::client (
  $shortname,
  $secret,
  $ip             = undef,
  $ip6            = undef,
  $virtual_server = undef,
  $nastype        = undef,
  $netmask        = undef,
  $redirect       = undef,
  $port           = undef,
  $srcip          = undef,
  $firewall       = false,
  $ensure         = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group
  $fr_version  = $::freeradius::params::fr_version

  # Calculate CIDR format IP now that FreeRADIUS has obsoleted use of separate netmask.
  # This workaround means no syntax change is necessary, although we print a warning.
  $cidr = $netmask ? {
    undef   => $ip,
    default => "${ip}/${netmask}",
  }
  $cidr6 = $netmask ? {
    undef   => $ip6,
    default => "${ip6}/${netmask}",
  }

  if ($netmask) {
    warning("netmask field found in client ${shortname} is deprecated, use CIDR notation instead. Please fix your configuration.")
  }

  file { "${fr_basepath}/clients.d/${shortname}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template("freeradius/client.conf.fr${fr_version}.erb"),
    require => [File["${fr_basepath}/clients.d"], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  if ($firewall and $ensure == 'present') {
    if $port {
      if $ip {
        firewall { "100-${shortname}-${port}-v4":
          proto  => 'udp',
          dport  => $port,
          action => 'accept',
          source => $cidr,
        }
      } elsif $ip6 {
        firewall { "100-${shortname}-${port}-v6":
          proto    => 'udp',
          dport    => $port,
          action   => 'accept',
          provider => 'ip6tables',
          source   => $cidr6,
        }
      }
    } else {
      fail('Must specify $port if you specify $firewall')
    }
  }
}
