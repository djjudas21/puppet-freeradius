# Configure Kerberos support for FreeRADIUS
define freeradius::krb5 (
  $keytab,
  $principal,
  $start       = "\${thread[pool].start_servers}",
  $min         = "\${thread[pool].min_spare_servers}",
  $max         = "\${thread[pool].max_servers}",
  $spare       = "\${thread[pool].max_spare_servers}",
  $ensure      = 'present',
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
