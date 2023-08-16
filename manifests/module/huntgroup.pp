# @summary freeradius::module::huntgroup
#
# @param conditions
# @param order
# @param huntgroup
define freeradius::module::huntgroup (
  Variant[String,Array] $conditions,
  Variant[String,Integer] $order     = 50,
  Optional[String] $huntgroup        = undef,
) {
  warning('Use of freeradius::module::huntgroup is deprecated. Use freeradius::huntgroup instead')

  freeradius::huntgroup { $name:
    conditions => $conditions,
    order      => $order,
  }
}
