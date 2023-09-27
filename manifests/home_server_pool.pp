# @summary Configure home server pools
#
# @param home_server
#   An array of one or more home servers (this must be an array even if you only have one home server). The names
#   of the home servers are NOT the hostnames, but the names of the sections. (e.g. `home_server foo {...}` has name "foo".
#
#   Note that ALL home servers listed here have to be of the same type. i.e. they all have to be "auth", or they all have to
#   be "acct", or they all have to be "auth+acct".
# @param type
#   The type of this pool controls how home servers are chosen.
#
#   * `fail-over` the request is sent to the first live home server in the list. i.e. If the first home server is marked "dead", the second
#     one is chosen, etc.
#   * `load-balance` the least busy home server is chosen For non-EAP auth methods, and for acct packets, we recommend using "load-balance".
#     It will ensure the highest availability for your network.
#   * `client-balance` the home server is chosen by hashing the source IP address of the packet. This configuration is most useful to do
#     simple load balancing for EAP sessions
#   * `client-port-balance` the home server is chosen by hashing the source IP address and source port of the packet.
#   * `keyed-balance` the home server is chosen by hashing (FNV) the contents of the Load-Balance-Key attribute from the control items.
# @param virtual_server
#   A `virtual_server` may be specified here.  If so, the "pre-proxy" and "post-proxy" sections are called when
#   the request is proxied, and when a response is received.
# @param fallback
#   If ALL home servers are dead, then this "fallback" home server is used. If set, it takes precedence over any realm-based
#   fallback, such as the DEFAULT realm.
#
#   For reasons of stability, this home server SHOULD be a virtual server. Otherwise, the fallback may itself be dead!
define freeradius::home_server_pool (
  Variant[String, Array[String]] $home_server,
  Enum['fail-over', 'load-balance', 'client-balance', 'client-port-balance', 'keyed-balance'] $type = 'fail-over',
  Optional[String] $virtual_server = undef,
  Optional[String] $fallback       = undef,
) {
  # Configure config fragment for this home server
  concat::fragment { "homeserverpool-${name}":
    target  => 'freeradius proxy.conf',
    content => template('freeradius/home_server_pool.erb'),
    order   => 20,
  }
}
