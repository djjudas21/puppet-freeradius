# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::statusclient (
  $ip=undef,
  $ip6=undef,
  $secret,
  $port=undef,
  $shortname,
  $netmask = undef,
) {
  file { "/etc/raddb/statusclients.d/${name}.conf":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/client.conf.erb'),
    require => File['/etc/raddb/clients.d'],
    notify  => Service['radiusd'],
  }
}
