# Install FreeRADIUS clients (WISMs or testing servers)
define freeradius::statusclient (
  Freeradius::Secret $secret,
  Optional[String] $ip        = undef,
  Optional[String] $ip6       = undef,
  Optional[Integer] $port     = undef,
  Optional[String] $shortname = $name,
  Freeradius::Ensure $ensure  = present,
) {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  file { "${basepath}/statusclients.d/${name}.conf":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    content => template('freeradius/client.conf.erb'),
    require => [File["${basepath}/clients.d"], Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }
}
