# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::statusclient (
  Freeradius::Secret $secret,
  Optional[String] $ip        = undef,
  Optional[String] $ip6       = undef,
  Optional[Integer] $port     = undef,
  Optional[String] $shortname = $name,
  Freeradius::Ensure $ensure  = present,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "freeradius statusclients.d/${name}.conf":
    ensure  => $ensure,
    path    => "${fr_basepath}/statusclients.d/${name}.conf",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/client.conf.erb'),
    require => [File['freeradius clients.d'], Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
}
