# @summary Set up proxy realms
#
# Define a realm in `proxy.conf`. Realms point to pools of home servers.
#
# @param virtual_server
#   Set this to "proxy" requests internally to a virtual server. The pre-proxy and post-proxy sections are run just as with any
#   other kind of home server.  The virtual server then receives the request, and replies, just as with any other packet.
#   Once proxied internally like this, the request CANNOT be proxied internally or externally.
# @param auth_pool
#   For authentication, the `auth_pool` configuration item should point to a `home_server_pool` that was previously
#   defined.  All of the home servers in the `auth_pool` must be of type `auth`.
# @param acct_pool
#   For accounting, the `acct_pool` configuration item should point to a `home_server_pool` that was previously
#   defined.  All of the home servers in the `acct_pool` must be of type `acct`.
# @param pool
#   If you have a `home_server_pool` where all of the home servers are of type `auth+acct`, you can just use the `pool`
#   configuration item, instead of specifying both `auth_pool` and `acct_pool`.
# @param nostrip
#   Normally, when an incoming User-Name is matched against the realm, the realm name is "stripped" off, and the "stripped"
#   user name is used to perform matches.If you do not want this to happen, set this to `true`.
# @param order
#   Set custom order of realm fragments, otherwise they are automatically ordered alphabetically.
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
