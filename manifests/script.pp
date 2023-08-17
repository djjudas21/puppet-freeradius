# Install FreeRADIUS helper scripts
define freeradius::script (
  String $source,
  Freeradius::Ensure $ensure = present,
) {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  file { "${basepath}/scripts/${name}":
    ensure  => $ensure,
    mode    => '0750',
    owner   => 'root',
    group   => $group,
    source  => $source,
    require => [File["${basepath}/scripts"], Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }
}
