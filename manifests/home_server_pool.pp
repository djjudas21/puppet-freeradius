# Configure home server pools
define freeradius::home_server_pool (
  Variant[String, Array[String]] $home_server,
  Enum['fail-over', 'load-balance', 'client-balance', 'client-port-balance', 'keyed-balance'] $type = 'fail-over',
  Optional[String] $virtual_server = undef,
  Optional[String] $fallback       = undef,
) {
  $basepath = $freeradius::basepath

  # Configure config fragment for this home server
  concat::fragment { "homeserverpool-${name}":
    target  => "${basepath}/proxy.conf",
    content => template('freeradius/home_server_pool.erb'),
    order   => 20,
  }
}
