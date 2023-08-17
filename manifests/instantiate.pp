# Instantiate a module in global config
define freeradius::instantiate (
  Freeradius::Ensure $ensure = present,
) {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  file { "${basepath}/instantiate/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    content => $name,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }
}
