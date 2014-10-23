# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::statusclient (
  $ip=undef,
  $ip6=undef,
  $secret,
  $port=undef,
  $shortname=$name,
  $netmask = undef,
) {
  $fr_package = $::freeradius::params::fr_package
  $fr_service = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_user = $::freeradius::params::fr_user

  file { "${fr_basepath}/statusclients.d/${name}.conf":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/client.conf.erb'),
    require => File["${fr_basepath}/clients.d"],
    notify  => Service[$fr_service],
  }
}
