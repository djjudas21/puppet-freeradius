# Set up proxy realms
define freeradius::realm (
  Optional[String] $virtual_server = undef,
  Optional[String] $auth_pool      = undef,
  Optional[String] $acct_pool      = undef,
  Optional[String] $pool           = undef,
  Optional[Boolean] $nostrip       = false,
  Optional[Integer] $order         = 30,
) {
  # Configure config fragment for this realm
  concat::fragment { "freeradius realm-${name}":
    target  => 'freeradius proxy.conf',
    content => template('freeradius/realm.erb'),
    order   => $order,
  }
}
