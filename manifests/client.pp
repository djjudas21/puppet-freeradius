# @summary Install FreeRADIUS clients (WISMs or testing servers)
#
# Define RADIUS clients as seen in `clients.conf`
#
# @example Single host
#   freeradius::client { "wlan-controller01":
#     ip        => '192.168.0.1',
#     secret    => 'testing123',
#     shortname => 'wlc01',
#     nastype   => 'other',
#     port      => '1645-1646',
#     firewall  => true,
#   }
#
# @example Range
#   freeradius::client { "wlan-controllers":
#     ip        => '192.168.0.0/24',
#     secret    => 'testing123',
#     shortname => 'wlc01',
#     nastype   => 'other',
#     port      => '1645-1646',
#     firewall  => true,
#   }
#
# @example Huntgroup
#   freeradius::client { "asa01":
#     ip         => '192.168.0.1',
#     secret     => 'testing123',
#     huntgroups => [
#       { name       => 'firewall',
#         conditions => [ 'NAS-IP-Address == 192.168.0.1' ] },
#     ]
#   }
#
# @param secret
#   The RADIUS shared secret used for communication between the client/NAS and the RADIUS server.
# @param shortname
#   A short alias that is used in place of the IP address or fully qualified hostname provided in the first line of the section.
# @param ip
#   The IP address of the client or range in CIDR format.
#   For IPv6, use `ipv6addr`. `ip` and `ip6` are mutually exclusive but one must be supplied.
# @param ip6
#   The IPv6 address of the client or range in CIDR format. `ip` and `ip6` are mutually exclusive but one must be supplied.
# @param proto
#   Transport protocol used by the client. If unspecified, defaults to "udp", which is the traditional RADIUS transport.
# @param require_message_authenticator
#   Old-style clients do not send a Message-Authenticator in an Access-Request.
#   RFC 5080 suggests that all clients SHOULD include it in an Access-Request.
# @param virtual_server
#   The virtual server that traffic from this client should be sent to.
# @param nastype
#   Used to tell the `checkrad.pl` script which NAS-specific method it should use when checking simultaneous use.
#   See [`man clients.conf`](http://freeradius.org/radiusd/man/clients.conf.txt) for a list of all options.
# @param login
#   Used by checkrad.pl when querying the NAS for simultaneous use.
# @param password
#   Used by checkrad.pl when querying the NAS for simultaneous use.
# @param coa_server
#   A pointer to the `home_server_pool` OR a `home_server` section that contains the CoA configuration for this client.
# @param response_window
#   Response window for proxied packets.
# @param max_connections
#   Limit the number of simultaneous TCP connections from a client. It is ignored for clients sending UDP traffic.
# @param lifetime
#   The lifetime, in seconds, of a TCP connection. It is ignored for clients sending UDP traffic.
# @param idle_timeout
#   The idle timeout, in seconds, of a TCP connection. It is ignored for clients sending UDP traffic.
# @param redirect
# @param port
#   The UDP port that this virtual server should listen on. Leave blank if this client is not tied to a virtual server.
#   Currently the port number is only used to create firewall exceptions and you only need to specify it if you set `firewall => true`.
#   Use port range syntax as in [`puppetlabs-firewall`](https://forge.puppetlabs.com/puppetlabs/firewall).
# @param srcip
# @param firewall
#   Create a firewall exception for this virtual server. If this is set to `true`, you must also supply `port` and either `ip` or `ip6`.
# @param ensure
# @param attributes
#   Array of attributes to assign to this client.
# @param huntgroups
#   Array of hashes, each hash defines one freeradius::huntgroup. Hash keys are all passed to a new instance of freeradius::huntgroup.
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
  $fr_basepath = $freeradius::params::fr_basepath
  $fr_group    = $freeradius::params::fr_group

  file { "freeradius clients.d/${shortname}.conf":
    ensure  => $ensure,
    path    => "${fr_basepath}/clients.d/${shortname}.conf",
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
          proto  => 'udp',
          dport  => $port,
          action => 'accept',
          source => $ip,
        }
      } elsif $ip6 {
        firewall { "100 ${name} ${port_description} v6":
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
    $huntgroups.each |$index, $huntgroup| {
      freeradius::huntgroup { "huntgroup.client.${name}.${index}":
        * => $huntgroup,
      }
    }
  }
}
