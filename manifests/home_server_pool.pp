# Configure home server pools
define freeradius::home_server_pool (
  $home_server,
  $type = 'fail-over',
  $virtual_server = undef,
  $fallback = undef,
) {
  $fr_basepath = $::freeradius::params::fr_basepath

  # Validate multi-value options
  unless $type in ['fail-over', 'load-balance', 'client-balance', 'client-port-balance', 'keyed-balance'] {
    fail('$type must be one of fail-over, load-balance, client-balance, client-port-balance, keyed-balance')
  }

  # Configure config fragment for this home server
  concat::fragment { "homeserverpool-${name}":
    target  => "${fr_basepath}/proxy.conf",
    content => template('freeradius/home_server_pool.erb'),
    order   => 20,
  }
}

