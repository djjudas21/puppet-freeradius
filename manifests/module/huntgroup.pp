# @summary Creates a huntgroup entry in a huntgroup file
#
# Deprected: Use `freeradius::huntgroup` instead
#
# @see `freeradius::module::preprocess`
#
# @param conditions
#   Array of rules to match in this huntgroup.
# @param order
#   Order of this huntgroup in the huntgroup files. This is the `order` parameter for the underlying `concat::fragment`.
# @param huntgroup
#   The path of the huntgroup file.
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
