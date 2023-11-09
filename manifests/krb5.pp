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
  $fr_package          = $::freeradius::params::fr_package
  $fr_service          = $::freeradius::params::fr_service
  $fr_modulepath       = $::freeradius::params::fr_modulepath
  $fr_basepath         = $::freeradius::params::fr_basepath
  $fr_group            = $::freeradius::params::fr_group

  # Generate a module config
  file { "${fr_basepath}/mods-available/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/krb5.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
  file { "${fr_modulepath}/${name}":
    ensure => link,
    target => "../mods-available/${name}",
  }
}
