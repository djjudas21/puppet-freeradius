# Install FreeRADIUS huntgroups
define freeradius::huntgroup (
  $ensure      = present,
  $huntgroup,
  $conditions  = [],
  $order       = 50,
) {

  $conditionals = join($conditions, ", ")

  $content    = "${huntgroup}\t${conditionals}\n\n"

  concat::fragment { "huntgroup.${title}":
    ensure  => $ensure,
    target  => "${fr_basepath}/huntgroups",
    content => $content,
    order   => $order,
  }
}
