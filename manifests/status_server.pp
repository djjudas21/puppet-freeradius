# @summary Enable status-server
#
# @param port
#   The port to listen for status requests on.
# @param listen
#   The address to listen on. Defaults to listen on all addresses but you could set this to `$::ipaddress` or `127.0.0.1`.
class freeradius::status_server (
  Optional[Integer] $port  = 18121,
  Optional[String] $listen = '*',
) {
  freeradius::site { 'status':
    content => template('freeradius/sites-enabled/status.erb'),
  }
}
