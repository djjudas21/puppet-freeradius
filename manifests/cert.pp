# Install FreeRADIUS certificates
define freeradius::cert (
  $source,
  $type = 'key',
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/certs/${name}":
    mode    => $type ? {
      'key'   => '0640',
      'cert'  => '0644',
      default => '0644',
    },
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [File["${fr_basepath}/certs"], Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
