# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::client (
  $shortname,
  $secret,
  $ip=undef,
  $ip6=undef,
  $net=undef,
  $server=undef,
  $virtual_server=undef,
  $nastype=undef,
  $netmask=undef,
  $redirect=undef,
  $port=undef,
  $srcip=undef,
) {
  $fr_package = $::freeradius::params::fr_package
  $fr_service = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_user = $::freeradius::params::fr_user

  file { "${fr_basepath}/clients.d/${shortname}.conf":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/client.conf.erb'),
    require => File["${fr_basepath}/clients.d"],
    notify  => Service[$fr_service],
  }
}
