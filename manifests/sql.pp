# Configure SQL support for FreeRADIUS
define freeradius::sql (
  $database,
  $password,
  $server = 'localhost',
  $login = 'radius',
  $radius_db = 'radius',
  $num_sql_socks = '${thread[pool].max_servers}',
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Validate our inputs
  if ($database != 'mysql' and $database != 'mssql' and $database != 'oracle' and $database != 'postgresql') {
    error('$database must be one of mysql, mssql, oracle, postgresql')
  }

  # Generate a module config, based on sql.conf 
  file { "${fr_basepath}/modules/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/sql.conf.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

}
