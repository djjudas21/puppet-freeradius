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
  # Validate multiple choice options
  unless $database in ['mysql', 'mssql', 'oracle', 'postgresql'] {
    fail('$database must be one of mysql, mssql, oracle, postgresql')
  }

  # Hostnames
  unless (is_hostname($server) or is_ip_address($server)) {
    fail('$server must be a valid hostname or IP address')
  }

  # Validate integers
  unless is_integer($port) {
    fail('$port must be an integer')
  }
  unless is_integer($num_sql_socks) {
    fail('$num_sql_socks must be an integer')
  }
  unless is_integer($lifetime) {
    fail('$lifetime must be an integer')
  }
  unless is_integer($max_queries) {
    fail('$max_queries must be an integer')
  }
  unless is_integer($connect_failure_retry_delay) {
    fail('$connect_failure_retry_delay must be an integer')
  }

  # Fake booleans (FR uses yes/no instead of true/false)
  unless $deletestalesessions in ['yes', 'no'] {
    fail('$deletestalesessions must be yes or no')
  }
  unless $sqltrace in ['yes', 'no'] {
    fail('$sqltrace must be yes or no')
  }
  unless $read_groups in ['yes', 'no'] {
    fail('$read_groups must be yes or no')
  }
  unless $readclients in ['yes', 'no'] {
    fail('$readclients must be yes or no')
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
