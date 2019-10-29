# Install FreeRADIUS helper scripts
define freeradius::script (
  String $source,
  Freeradius::Ensure $ensure = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/scripts/${name}":
    ensure  => $ensure,
    mode    => '0750',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [File["${fr_basepath}/scripts"], Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
