# @summary Configure Kerberos support for FreeRADIUS
#
# @param keytab
#   Full path to the Kerberos keytab file
# @param principal
#   Name of the service principal
# @param start
#   Connections to create during module instantiation. If the server cannot create specified number of
#   connections during instantiation it will exit. Set to 0 to allow the server to start without the
#   directory being available.
# @param min
#   Minimum number of connections to keep open.
# @param max
#   Maximum number of connections.
# @param spare
#   Spare connections to be left idle.
# @param ensure
define freeradius::krb5 (
  String $keytab,
  String $principal,
  Freeradius::Integer  $start = "\${thread[pool].start_servers}",
  Freeradius::Integer  $min   = "\${thread[pool].min_spare_servers}",
  Freeradius::Integer  $max   = "\${thread[pool].max_servers}",
  Freeradius::Integer  $spare = "\${thread[pool].max_spare_servers}",
  Freeradius::Ensure $ensure  = 'present',
) {
  $fr_modulepath       = $freeradius::params::fr_modulepath
  $fr_basepath         = $freeradius::params::fr_basepath
  $fr_group            = $freeradius::params::fr_group

  # Generate a module config
  file { "freeradius mods-available/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/mods-available/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/krb5.erb'),
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
  file { "freeradius mods-enabled/${name}":
    ensure => link,
    path   => "${fr_modulepath}/${name}",
    target => "../mods-available/${name}",
  }
}
