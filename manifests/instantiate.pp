# @summary Instantiate a module in global config
#
# Instantiate a module that is not automatically instantiated.
#
# @example
#   freeradius::instantiate { 'mymodule': }
#
# @param ensure
define freeradius::instantiate (
  Freeradius::Ensure $ensure = present,
) {
  $fr_basepath = $freeradius::params::fr_basepath
  $fr_group    = $freeradius::params::fr_group

  file { "freeradius instantiate/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/instantiate/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => $name,
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
}
