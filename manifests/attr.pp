# Install FreeRADIUS config snippets
define freeradius::attr ($source) {
  $fr_package = $::freeradius::params::fr_package
  $fr_service = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_user = $::freeradius::params::fr_user

  file { "${fr_basepath}/attr.d/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => File["${fr_basepath}/attr.d"],
    notify  => Service[$fr_service],
  }
}
