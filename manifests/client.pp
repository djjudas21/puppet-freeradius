# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::client (
  $secret,
  $shortname                     = $title,
  $ip                            = undef,
  $ip6                           = undef,
  $proto                         = undef,
  $require_message_authenticator = 'no',
  $virtual_server                = undef,
  $nastype                       = undef,
  $login                         = undef,
  $password                      = undef,
  $coa_server                    = undef,
  $response_window               = undef,
  $max_connections               = undef,
  $lifetime                      = undef,
  $idle_timeout                  = undef,
  $redirect                      = undef,
  $port                          = undef,
  $srcip                         = undef,
  $firewall                      = false,
  $ensure                        = present,
  $attributes                    = [],
  $huntgroups                    = undef,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  if $proto {
    unless $proto in ['*', 'udp', 'tcp'] {
      fail('$proto must be one of udp, tcp or *')
    }
  }

  unless $require_message_authenticator in ['yes', 'no'] {
    fail('$require_message_authenticator must be one of yes or no')
  }

  if $nastype {
    unless $nastype in ['cisco', 'computone', 'livingston', 'juniper', 'max40xx',
    'multitech', 'netserver', 'pathras', 'patton', 'portslave', 'tc', 'usrhiper', 'other'] {
      fail('$nastype must be one of cisco, computone, livingston, juniper, max40xx, multitech, netserver, pathras, patton, portslave, tc, usrhiper, other')
    }
  }

  file { "${fr_basepath}/clients.d/${shortname}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/client.conf.erb'),
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
          source => $ip,
        }
      } elsif $ip6 {
        firewall { "100-${shortname}-${port}-v6":
          proto    => 'udp',
          dport    => $port,
          action   => 'accept',
          provider => 'ip6tables',
          source   => $ip6,
        }
      }
    } else {
      fail('Must specify $port if you specify $firewall')
    }
  }

  if $huntgroups {
    $huntgroups.each { |index, huntgroup|
      freeradius::huntgroup { "huntgroup.client.${shortname}.${index}":
        * => $huntgroup
      }
    }
  }
}
