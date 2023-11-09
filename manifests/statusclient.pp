# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::statusclient (
  Freeradius::Secret $secret,
  Optional[String] $ip        = undef,
  Optional[String] $ip6       = undef,
  Optional[Integer] $port     = undef,
  Optional[String] $shortname = $name,
  Freeradius::Ensure $ensure  = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/statusclients.d/${name}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/client.conf.erb'),
    require => [File["${fr_basepath}/clients.d"], Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
