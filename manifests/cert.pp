# Install FreeRADIUS certificates
define freeradius::cert (
  $source = undef,
  $content = undef,
  $type = 'key',
  $ensure = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  $permission = $type ? {
    'key'   => '0640',
    'cert'  => '0644',
    default => '0644',
  }

  file { "${fr_basepath}/certs/${name}":
    ensure    => $ensure,
    mode      => $permission,
    owner     => 'root',
    group     => $fr_group,
    source    => $source,
    content   => $content,
    show_diff => false,
    require   => [File["${fr_basepath}/certs"], Package[$fr_package], Group[$fr_group]],
    notify    => Service[$fr_service],
  }
}
