# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::statusclient ($secret, $ip = undef, $ip6 = undef, $port = undef, $shortname = $name, $netmask = undef,) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/statusclients.d/${name}.conf":
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/client.conf.erb'),
    require => [File["${fr_basepath}/clients.d"], Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
