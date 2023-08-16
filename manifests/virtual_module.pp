# Define a virtual module, made up of others
define freeradius::virtual_module (
  Array[String, 1] $submodules,
  Freeradius::Ensure $ensure = present,
  Enum['redundant','load-balance','redundant-load-balance','group'] $type = 'redundant-load-balance',
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
    content => template('freeradius/virtual_module.erb'),
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }
}
