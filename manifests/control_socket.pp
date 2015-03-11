# Configure the FreeRADIUS control_socket
class freeradius::control_socket (
  $mode = 'ro',
) {
  $fr_user  = $::freeradius::params::fr_user
  $fr_group = $::freeradius::params::fr_group

  unless $mode in ['ro', 'rw'] {
    fail('$mode must be ro or rw')
  }

  freeradius::site { 'control-socket':
    content => template('freeradius/sites-enabled/control-socket.erb'),
  }
}
