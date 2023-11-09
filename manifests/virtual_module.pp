# Define a virtual module, made up of others
define freeradius::virtual_module (
  Array[String] $submodules,
  Freeradius::Ensure $ensure = present,
  Enum['redundant','load-balance','redundant-load-balance','group'] $type = 'redundant-load-balance',
  ) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Make sure $submodules is a non-zero array
  validate_array($submodules)
  if count($submodules) < 1 {
    fail('Must specify at least one $submodule')
  }

  file { "${fr_basepath}/instantiate/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/virtual_module.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
