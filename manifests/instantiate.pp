# Instantiate a module in global config
define freeradius::instantiate {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/instantiate/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => $name,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
