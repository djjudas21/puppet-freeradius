# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::client (
  Freeradius::Secret $secret,
  Optional[String] $shortname                        = $title,
  Optional[String] $ip                               = undef,
  Optional[String] $ip6                              = undef,
  Optional[Enum['*', 'udp', 'tcp']] $proto           = '*',
  Freeradius::Boolean $require_message_authenticator = 'no',
  Optional[String] $virtual_server                   = undef,
  Optional[Enum[
    'cisco',
    'computone',
    'livingston',
    'juniper',
    'max40xx',
    'multitech',
    'netserver',
    'pathras',
    'patton',
    'portslave',
    'tc',
    'usrhiper',
    'other',
  ]] $nastype = undef,
  Optional[String] $login                            = undef,
  Optional[Freeradius::Password] $password           = undef,
  Optional[String] $coa_server                       = undef,
  Optional[String] $response_window                  = undef,
  Optional[Integer] $max_connections                 = undef,
  Optional[Integer] $lifetime                        = undef,
  Optional[Integer] $idle_timeout                    = undef,
  Optional[String] $redirect                         = undef,
  Optional[Variant[Integer,Array[Integer]]] $port    = undef,
  Optional[String] $srcip                            = undef,
  Boolean $firewall                                  = false,
  Freeradius::Ensure $ensure                         = present,
  Variant[Array, Hash, String] $attributes           = [],
  Optional[String] $huntgroups                       = undef,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "freeradius clients.d/${name}.conf":
    ensure  => $ensure,
    path    => "${fr_basepath}/clients.d/${name}.conf",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/client.conf.erb'),
    require => [File['freeradius clients.d'], Group['radiusd']],
    notify  => Service['radiusd'],
  }

  if ($firewall and $ensure == 'present') {
    if $port =~ Array {
      $port_description = $port.join(',')
    } else {
      $port_description = $port
    }

    if $port {
      if $ip {
        firewall { "100 ${name} ${port_description} v4":
          proto    => 'udp',
          dport    => $port,
          jump     => 'ACCEPT',
          protocol => 'IPv4',
          source   => $ip,
        }
      } elsif $ip6 {
        firewall { "100 ${name} ${port_description} v6":
          proto    => 'udp',
          dport    => $port,
          jump     => 'ACCEPT',
          protocol => 'IPv6',
          source   => $ip6,
        }
      }
    } else {
      fail('Must specify $port if you specify $firewall')
    }
  }

  if $huntgroups {
    $huntgroups.each |$index, $huntgroup| {
      freeradius::huntgroup { "huntgroup.client.${name}.${index}":
        * => $huntgroup
      }
    }
  }
}
