# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::client (
  $ip=undef,
  $ip6=undef,
  $net=undef,
  $shortname,
  $secret,
  $server=undef,
  $virtual_server=undef,
  $nastype=undef,
  $netmask=undef,
  $redirect=undef,
  $port=undef,
  $srcip=undef,
) {
  file { "/etc/raddb/clients.d/${shortname}.conf":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/client.conf.erb'),
    require => File['/etc/raddb/clients.d'],
    notify  => Service['radiusd'],
  }
}
