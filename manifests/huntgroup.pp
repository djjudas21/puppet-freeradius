# Install FreeRADIUS huntgroups
define freeradius::huntgroup (
  Freeradius::Ensure $ensure                = present,
  Optional[String] $huntgroup               = $title,
  Optional[Array[String]] $conditions       = [],
  Optional[Variant[String, Integer]] $order = 50,
) {
  concat::fragment { "huntgroup.${title}":
    target  => 'freeradius mods-config/preprocess/huntgroups',
    content => template('freeradius/huntgroup.erb'),
    order   => $order,
    notify  => Service['radiusd'],
  }
}
