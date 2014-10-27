# Enable status-server
class freeradius::status_server (
  $secret,
  $port     = '18121',
  $listen   = '*',
  $enable   = true,
) {
  freeradius::site { 'status':
    content => $enable ? {
      true    => template('freeradius/sites-enabled/status.erb'),
      default => '# Status server disabled',
    }
  }
}
