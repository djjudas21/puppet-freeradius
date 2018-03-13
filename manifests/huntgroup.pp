# Install FreeRADIUS huntgroups
define freeradius::huntgroup (
  $ensure      = present,
  $huntgroup   = $title,
  $conditions  = [],
  $order       = 50,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_service  = $::freeradius::params::fr_service

  concat::fragment { "huntgroup.${title}":
    target  => "${fr_basepath}/mods-config/preprocess/huntgroups",
    content => template('freeradius/huntgroup.erb'),
    order   => $order,
    notify  => Service[$fr_service],
  }
}
