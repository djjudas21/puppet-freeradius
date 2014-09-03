# Instantiate a module in global config
define freeradius::instantiate {
  $fr_package = $::freeradius::params::fr_package
  $fr_service = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_user = $::freeradius::params::fr_user

  file { "${fr_basepath}/instantiate/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    content => $name,
    require => Package[$fr_package],
    notify  => Service[$fr_service],
  }
}
