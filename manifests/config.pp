# Install FreeRADIUS config snippets
define freeradius::config ($source) {
  $fr_package = $::freeradius::params::fr_package
  $fr_service = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_user = $::freeradius::params::fr_user

  file { "${fr_basepath}/conf.d/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => File["${fr_basepath}/conf.d"],
    notify  => Service[$fr_service],
  }
}
