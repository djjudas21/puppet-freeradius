# @summary Configure a home_server for proxy config
#
# @param secret
# @param proto
# @param status_check
# @param type
# @param check_interval
# @param check_timeout
# @param ipaddr
# @param ipv6addr
# @param max_outstanding
# @param no_response_fail
# @param num_answers_to_alive
# @param password
# @param port
# @param response_window
# @param revive_interval
# @param src_ipaddr
# @param username
# @param virtual_server
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
