# @summary Install FreeRADIUS clients (WISMs or testing servers)
#
# Define RADIUS clients, specifically to connect to the status server for monitoring.
# Very similar usage to `freeradius::client` but with fewer options.
#
# @param secret
#   The RADIUS shared secret used for communication between the client/NAS and the RADIUS server.
# @param ip
#   The IP address of the client in CIDR format. For IPv6, use `ipv6addr`. `ip` and `ip6` are mutually exclusive but one must be supplied.
# @param ip6
#   The IPv6 address of the client in CIDR format. `ip` and `ip6` are mutually exclusive but one must be supplied.
# @param port
#   The UDP port that this virtual server should listen on. Leave blank if this client is not tied to a virtual server.
# @param shortname
#   A short alias that is used in place of the IP address or fully qualified hostname provided in the first line of the section.
# @param ensure
define freeradius::statusclient (
  Freeradius::Secret $secret,
  Optional[String] $ip        = undef,
  Optional[String] $ip6       = undef,
  Optional[Integer] $port     = undef,
  Optional[String] $shortname = $name,
  Freeradius::Ensure $ensure  = present,
) {
  $fr_basepath = $freeradius::params::fr_basepath
  $fr_group    = $freeradius::params::fr_group

  file { "freeradius statusclients.d/${name}.conf":
    ensure  => $ensure,
    path    => "${fr_basepath}/statusclients.d/${name}.conf",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/client.conf.erb'),
    require => [File['freeradius clients.d'], Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
}
