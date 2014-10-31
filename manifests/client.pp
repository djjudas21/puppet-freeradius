# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::client (
  $shortname,
  $secret,
  $ip             = undef,
  $ip6            = undef,
  $net            = undef,
  $virtual_server = undef,
  $nastype        = undef,
  $netmask        = undef,
  $redirect       = undef,
  $port           = undef,
  $srcip          = undef,
  $firewall       = false,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/clients.d/${shortname}.conf":
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/client.conf.erb'),
    require => [File["${fr_basepath}/clients.d"], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  if $firewall {
    if $port {
      if $ip {
        firewall { "100-${shortname}-${port}-v4":
          proto  => 'udp',
          dport  => $port,
          action => 'accept',
          source => $net ? {
            undef   => $ip,
            default => "${ip}/${net}",
          },
        }
      } elsif $ip6 {
        firewall { "100-${shortname}-${port}-v6":
          proto    => 'udp',
          dport    => $port,
          action   => 'accept',
          provider => 'ip6tables',
          source   => $net ? {
            undef   => $ip6,
            default => "${ip6}/${net}",
          },
        }
      }
    } else {
      fail('Must specify $port if you specify $firewall')
    }
  }
}
