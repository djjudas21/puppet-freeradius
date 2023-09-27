# @summary Install a `ippool` module
#
# @param range_start
#   The first IP address of the pool.
# @param range_stop
#   The last IP address of the pool.
# @param netmask
#   The network mask used for the pool
# @param ensure
#   If the module should `present` or `absent`.
# @param cache_size
#   The gdbm cache size for the db files.
#   Defaults to the number of IP addresses in the range.
# @param filename
#   The main db file used to allocate address.
# @param ip_index
#   Helper db index file.
# @param override
#   If set, the Framed-IP-Address already in the reply (if any) will be discarded.
# @param maximum_timeout
#   Maximum time in seconds that an entry may be active.
# @param key
#   The key to use for the session database.
define freeradius::module::ippool (
  String $range_start,
  String $range_stop,
  String $netmask,
  Freeradius::Ensure $ensure    = 'present',
  Optional[Integer] $cache_size = undef,
  String $filename              = "\${db_dir}/db.${name}",
  String $ip_index              = "\${db_dir}/db.${name}.index",
  Freeradius::Boolean $override = 'no',
  Integer $maximum_timeout      = 0,
  Optional[String] $key         = undef,
) {
  if ($cache_size !~ Undef) {
    $real_cache_size = $cache_size
  } else {
    $real_cache_size = inline_template(@("IPADDRRANGE"/L)
        <%- require 'ipaddr' -%><%=(IPAddr.new @range_stop).to_i - (IPAddr.new @range_start).to_i + 1 %>
        |-IPADDRRANGE
    )
  }

  freeradius::module { "ippool_${name}":
    ensure  => $ensure,
    content => template('freeradius/ippool.erb'),
  }

  $_file_path = $filename =~ Stdlib::AbsolutePath ? {
    true    => $filename,
    default => regsubst($filename, /\${db_dir}/, $freeradius::params::fr_basepath),
  }
  $_index_path = $ip_index =~ Stdlib::AbsolutePath ? {
    true    => $ip_index,
    default => regsubst($ip_index, /\${db_dir}/, $freeradius::params::fr_basepath),
  }
  file { $_file_path:
    ensure => file,
    owner  => $freeradius::params::fr_user,
    group  => $freeradius::params::fr_group,
    mode   => '0640',
  }
  file { $_index_path:
    ensure => file,
    owner  => $freeradius::params::fr_user,
    group  => $freeradius::params::fr_group,
    mode   => '0640',
  }
}
