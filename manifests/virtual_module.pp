# Define a virtual module, made up of others
define freeradius::virtual_module (
  Array[String, 1] $submodules,
  Freeradius::Ensure $ensure = present,
  Enum['redundant','load-balance','redundant-load-balance','group'] $type = 'redundant-load-balance',
  ) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "freeradius instantiate/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/instantiate/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/virtual_module.erb'),
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
}
