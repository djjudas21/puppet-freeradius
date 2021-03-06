# Enable status-server
class freeradius::status_server (
  Optional[Integer] $port  = 18121,
  Optional[String] $listen = '*',
) {
  freeradius::site { 'status':
    content => template('freeradius/sites-enabled/status.erb'),
  }
}
