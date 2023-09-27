# @summary Install FreeRADIUS huntgroups
#
# Define a huntgroup given a name and the conditions under which a huntgroup matches a client.
#
# @example
#   freeradius::huntgroup { 'switchaccess':
#     huntgroup  => 'switchaccess',
#     conditions => [
#       'NAS-IP-Address == 192.168.0.1',
#     ],
#   }
#
# @param ensure
# @param huntgroup
#   Name of the huntgroup to assign, if conditions are all met.
# @param conditions
#   Array of conditions which are used to match the client, each element should contain a condition in the form of 'Key == Value'.
# @param order
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
