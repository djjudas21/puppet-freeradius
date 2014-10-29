# Default parameters for freeradius
class freeradius::params {

  # Name of FreeRADIUS package
  $fr_package = $::osfamily ? {
    'RedHat' => 'freeradius',
    'Debian' => 'freeradius',
    default  => 'freeradius',
  }

  # Name of FreeRADIUS service
  $fr_service = $::osfamily ? {
    'RedHat' => 'radiusd',
    'Debian' => 'freeradius',
    default  => 'radiusd',
  }

  # Default base path for FreeRADIUS configs
  $fr_basepath = $::osfamily ? {
    'RedHat' => '/etc/raddb',
    'Debian' => '/etc/freeradius',
    default  => '/etc/raddb',
  }

  # FreeRADIUS user
  $fr_user = $::osfamily ? {
    'RedHat' => 'radiusd',
    'Debian' => 'freerad',
    default  => 'radiusd',
  }

  # FreeRADIUS group
  $fr_group = $::osfamily ? {
    'RedHat' => 'radiusd',
    'Debian' => 'freerad',
    default  => 'radiusd',
  }
}
