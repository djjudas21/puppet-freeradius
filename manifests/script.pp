# @summary Install FreeRADIUS helper scripts
#
# @param source
# @param ensure
define freeradius::script (
  String $source,
  Freeradius::Ensure $ensure = present,
) {
  $fr_basepath = $freeradius::params::fr_basepath
  $fr_group    = $freeradius::params::fr_group

  file { "freeradius scripts/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/scripts/${name}",
    mode    => '0750',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [File['freeradius scripts'], Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
}
