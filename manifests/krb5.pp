# Configure Kerberos support for FreeRADIUS
define freeradius::krb5 (
  String $keytab,
  String $principal,
  Freeradius::Integer  $start = "\${thread[pool].start_servers}",
  Freeradius::Integer  $min   = "\${thread[pool].min_spare_servers}",
  Freeradius::Integer  $max   = "\${thread[pool].max_servers}",
  Freeradius::Integer  $spare = "\${thread[pool].max_spare_servers}",
  Freeradius::Ensure $ensure  = 'present',
) {
  $package_name          = $freeradius::package_name
  $service_name          = $freeradius::service_name
  $modulepath       = $freeradius::modulepath
  $basepath         = $freeradius::basepath
  $group            = $freeradius::group

  # Generate a module config
  file { "${basepath}/mods-available/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    content => template('freeradius/krb5.erb'),
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }
  file { "${modulepath}/${name}":
    ensure => link,
    target => "../mods-available/${name}",
  }
}
