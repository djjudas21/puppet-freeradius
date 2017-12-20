# Install FreeRADIUS huntgroups
define freeradius::huntgroup (
  $ensure      = present,
  $huntgroup   = $title,
  $conditions  = [],
  $order       = 50,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_service  = $::freeradius::params::fr_service

  $conditionals = join($conditions, ', ')

  $content    = "${huntgroup}\t${conditionals}\n"

  concat::fragment { "huntgroup.${title}":
    ensure  => $ensure,
    target  => "${fr_basepath}/mods-config/preprocess/huntgroups",
    content => $content,
    order   => $order,
    notify  => Service[$fr_service],
  }
}
