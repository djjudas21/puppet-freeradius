# @summary Configure the FreeRADIUS control_socket
#
# @param mode
class freeradius::control_socket (
  Enum['ro', 'rw'] $mode = 'ro',
) {
  $fr_user  = $freeradius::params::fr_user
  $fr_group = $freeradius::params::fr_group

  freeradius::site { 'control-socket':
    content => template('freeradius/sites-enabled/control-socket.erb'),
  }
}
