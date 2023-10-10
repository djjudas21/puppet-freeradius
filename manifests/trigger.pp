# Configure FreeRADIUS SNMP trap triggers
class freeradius::trigger (
  String $trigger_cmd = '/bin/echo',
  String $trap_community = 'public',
  String $trap_dest = '127.0.0.1',
  #Freeradius::Ensure $ensure = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Install policy in policy.d
  file { "${fr_basepath}/trigger.conf":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/trigger.conf.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
