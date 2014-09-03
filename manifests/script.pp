# Install FreeRADIUS helper scripts
define freeradius::script ($source) {
  $fr_package = $::freeradius::params::fr_package
  $fr_service = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_user = $::freeradius::params::fr_user

  file { "${fr_basepath}/scripts/${name}":
    mode    => '0750',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => File["${fr_basepath}/scripts"],
  }
}
