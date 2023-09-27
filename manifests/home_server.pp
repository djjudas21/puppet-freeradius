# @summary Configure a home_server for proxy config
#
# This section defines a "Home Server" which is another RADIUS server that gets sent proxied requests.
#
# @param secret
#   The shared secret use to "encrypt" and "sign" packets between FreeRADIUS and the home server.
# @param proto
# @param status_check
#   Type of check to see if the `home_server` is dead or alive.
# @param type
#   Home servers can be sent Access-Request packets or Accounting-Request packets. Allowed values are:
#   * `auth` Handles Access-Request packets
#   * `acct` Handles Accounting-Request packets
#   * `auth+acct` Handles Access-Request packets at "port" and Accounting-Request packets at "port + 1"
#   * `coa` Handles CoA-Request and Disconnect-Request packets.
# @param check_interval
# @param check_timeout
# @param ipaddr
#   IPv4 address or hostname of the home server. Specify one of `ipaddr`, `ipv6addr` or `virtual_server`
# @param ipv6addr
#   IPv6 address or hostname of the home server. Specify one of `ipaddr`, `ipv6addr` or `virtual_server`
# @param max_outstanding
# @param no_response_fail
# @param num_answers_to_alive
# @param password
# @param port
#   The transport protocol. If unspecified, defaults to "udp", which is the traditional
#   RADIUS transport. It may also be "tcp", in which case TCP will be used to talk to
#   this home server.
# @param response_window
# @param revive_interval
# @param src_ipaddr
# @param username
# @param virtual_server
#   If you specify a `virtual_server` here, then requests will be proxied internally to that virtual server.
#   These requests CANNOT be proxied again, however. The intent is to have the local server handle packets
#   when all home servers are dead. Specify one of `ipaddr`, `ipv6addr` or `virtual_server`
# @param zombie_period
define freeradius::home_server (
  Freeradius::Secret $secret,
  Enum['udp', 'tcp'] $proto                              = 'udp',
  Enum['none', 'status-server', 'request'] $status_check = 'none',
  Enum['auth', 'acct', 'auth+acct', 'coa'] $type         = 'auth',
  Optional[Integer] $check_interval                      = undef,
  Optional[Integer] $check_timeout                       = undef,
  Optional[String] $ipaddr                               = undef,
  Optional[String] $ipv6addr                             = undef,
  Optional[Integer] $max_outstanding                     = undef,
  Optional[Enum['no', 'yes']] $no_response_fail          = undef,
  Optional[Integer] $num_answers_to_alive                = undef,
  Optional[Freeradius::Password] $password               = undef,
  Optional[Integer] $port                                = 1812,
  Optional[Integer] $response_window                     = undef,
  Optional[Integer] $revive_interval                     = undef,
  Optional[String] $src_ipaddr                           = undef,
  Optional[String] $username                             = undef,
  Optional[String] $virtual_server                       = undef,
  Optional[Integer] $zombie_period                       = undef,
) {
  # Configure config fragment for this home server
  concat::fragment { "homeserver-${name}":
    target  => 'freeradius proxy.conf',
    content => template('freeradius/home_server.erb'),
    order   => 10,
  }
}
