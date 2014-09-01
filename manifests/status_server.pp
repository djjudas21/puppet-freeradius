class freeradius::status_server (
  $port     = '18121',
  $listen   = '*',
  $secret,
  $enable   = true,
) {
  freeradius::site { 'status':
    content => $enable ? {
      true    => template('freeradius/sites-enabled/status.erb'),
      default => '# Status server disabled',
    }
  }
}
