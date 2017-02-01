# Install FreeRADIUS huntgroups
define freeradius::huntgroup (
  $ensure      = present,
  $huntgroup,
  $conditions  = [],
  $order       = 50,
) {
  $fr_basepath = $::freeradius::params::fr_basepath

  $conditionals = join($conditions, ", ")

  $content    = "${huntgroup}\t${conditionals}\n\n"

  concat::fragment { "huntgroup.${title}":
    ensure  => $ensure,
    target  => "${fr_basepath}/mods-config/preprocess/huntgroups",
    content => $content,
    order   => $order,
  }
}
