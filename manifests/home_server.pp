# Configure a home_server for proxy config
define freeradius::home_server (
  String $secret,
  Enum['auth', 'acct', 'auth+acct', 'coa'] $type         = 'auth',
  Optional[String] $ipaddr                               = undef,
  Optional[String] $ipv6addr                             = undef,
  Optional[String] $virtual_server                       = undef,
  Optional[Integer] $port                                = 1812,
  Enum['udp', 'tcp'] $proto                              = 'udp',
  Enum['none', 'status-server', 'request'] $status_check = 'none',
) {
  $fr_basepath = $::freeradius::params::fr_basepath

  # Configure config fragment for this home server
  concat::fragment { "homeserver-${name}":
    target  => "${fr_basepath}/proxy.conf",
    content => template('freeradius/home_server.erb'),
    order   => 10,
  }
}
