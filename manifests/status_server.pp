class freeradius::status_server (
  $port     = '18121',
  $listen   = '*',
  $ipaddr   = '127.0.0.1',
  $secret,
  $firewall = false,
) {
  freeradius::site { 'status':
    content => template('freeradius/sites-enabled/status.erb'),
#    source => 'puppet:///modules/freeradius/sites-enabled/status',
  }

  if $firewall == true {
    firewall { '100-radius-status':
      proto  => 'udp',
      dport  => $port,
      source => $ipaddr,
      action => 'accept',
    }
  }
}
