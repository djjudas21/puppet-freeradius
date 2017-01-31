# == Define: freeradius::module::ippool
#
define freeradius::module::ippool (
  String $range_start,
  String $range_stop,
  String $netmask,
  $ensure                       = 'present',
  Optional[Integer] $cache_size = undef,
  String $filename              = "\${db_dir}/db.${name}",
  String $ip_index              = "\${db_dir}/db.${name}.index",
  Freeradius::Boolean $override = 'no',
  Integer $maximum_timeout      = 0,
  Optional[String] $key         = undef,
) {

  freeradius::module { "ippool_${name}":
    ensure  => $ensure,
    content => template('freeradius/ippool.erb'),
  }
}
