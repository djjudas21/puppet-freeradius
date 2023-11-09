# Install FreeRADIUS huntgroups
define freeradius::huntgroup (
  Freeradius::Ensure $ensure                = present,
  Optional[String] $huntgroup               = $title,
  Optional[Array[String]] $conditions       = [],
  Optional[Variant[String, Integer]] $order = 50,
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
