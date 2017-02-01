# == Define: freeradius::module::huntgroup
#
define freeradius::module::huntgroup (
  Variant[String,Array] $conditions,
  Variant[String,Integer] $order     = 50,
  String $huntgroup                  = 'huntgroup',
) {
  concat::fragment {"Huntgroup ${name}":
    target  => $huntgroup,
    order   => $order,
    content => template('freeradius/huntgroup.erb')
  }
}
