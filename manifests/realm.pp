# Set up proxy realms
define freeradius::realm (
  Optional[String] $virtual_server = undef,
  Optional[String] $auth_pool      = undef,
  Optional[String] $acct_pool      = undef,
  Optional[String] $pool           = undef,
  Optional[Boolean] $nostrip       = false,
  Optional[Integer] $order         = 30,
) {
  $fr_basepath = $::freeradius::params::fr_basepath

  # Configure config fragment for this realm
  concat::fragment { "realm-${name}":
    target  => "${fr_basepath}/proxy.conf",
    content => template('freeradius/realm.erb'),
    order   => $order,
  }
}
