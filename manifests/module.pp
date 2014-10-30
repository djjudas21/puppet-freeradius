# Install FreeRADIUS modules
define freeradius::module ($source) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/modules/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
