# Configure SQL support for FreeRADIUS
define freeradius::sql (
  $database,
  $password,
  $server = 'localhost',
  $login = 'radius',
  $radius_db = 'radius',
  $num_sql_socks = '${thread[pool].max_servers}',
  $query_file = 'sql/${database}/dialup.conf',
  $lifetime = '0',
  $max_queries = '0',
  $ensure = present,
  $acct_table1 = 'radacct',
  $acct_table2 = 'radacct',
  $postauth_table = 'radpostauth',
  $authcheck_table = 'radcheck',
  $authreply_table = 'radreply',
  $groupcheck_table = 'radgroupcheck',
  $groupreply_table = 'radgroupreply',
  $usergroup_table = 'radusergroup',
  $deletestalesessions = 'yes',
  $sqltrace = 'no',
  $sqltracefile = '${logdir}/sqltrace.sql',
  $connect_failure_retry_delay = '60',
  $nas_table = 'nas',
  $read_groups = 'yes',
  $port = '3306',
  $readclients = 'no',
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
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/sql.conf.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

}
