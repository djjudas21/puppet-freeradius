# Configure a home_server for proxy config
define freeradius::home_server (
  $secret,
  $type = 'auth',
  $ipaddr = undef,
  $ipv6addr = undef,
  $virtual_server = undef,
  $port = 1812,
  $proto = 'udp',
  $status_check = undef,
) {
  $fr_basepath = $::freeradius::params::fr_basepath

  # Validate multiple choice options
  unless $type in ['auth', 'acct', 'auth+acct', 'coa'] {
    fail('$type must be one of auth, acct, auth+acct, coa')
  }
  unless $proto in ['udp', 'tcp'] {
    fail('$type must be one of udp, tcp')
  }

  # Validate integers
  unless is_integer($port) {
    fail('$port must be an integer')
  }

  if $status_check {
    unless $status_check in ['none', 'status-server', 'request'] {
      fail('$status_check must be one of none, status-server, request')
    }
  }

  # Configure config fragment for this home server
  concat::fragment { "homeserver-${name}":
    target  => "${fr_basepath}/proxy.conf",
    content => template('freeradius/home_server.erb'),
    order   => 10,
  }
}

