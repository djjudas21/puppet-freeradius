# @summary Configure SQL support for FreeRADIUS
#
# Configure SQL connections. You can define multiple database connections by
# invoking this resource multiple times. If you are using MySQL, don't forget to
# also set `mysql_support => true` in the base `freeradius` class.
#
# @example
#   freeradius::sql { 'mydatabase':
#     database  => 'mysql',
#     server    => '192.168.0.1',
#     login     => 'radius',
#     password  => 'topsecret',
#     radius_db => 'radius',
#   }
#
# @param database
#   Specify which FreeRADIUS database driver to use.
# @param password
#   Password to connect to the database.
# @param server
#   Specify hostname of IP address of the database server.
# @param login
#   Username to connect to the databae.
# @param radius_db
#   Name of the database. Normally you should leave this alone.
#
#   If you are using Oracle then use this instead:
#   `(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SID=your_sid)))`.
# @param num_sql_socks
#   Number of sql connections to make to the database server.
#   Setting this to LESS than the number of threads means that some threads may starve, and
#   you will see errors like "No connections available and at max connection limit". Setting
#   this to MORE than the number of threads means that there are more connections than necessary.
#   Leave blank to set it to the same value as the number of threads.
# @param query_file
#   **`query_file` has been deprecated - use `custom_query_file` instead**
#
#   Relative path to the file which contains your SQL queries. By default, points to the `dialup.conf` specific to your database engine, so
#   leave this blank if you are using stock queries.
#
#   If you need to use custom queries, it is recommended that you deploy your query file using
#   `freeradius::script` to install the file into `scripts/custom_dialup.conf` and then
#   set `query_file` to `scripts/custom_dialup.conf`.
# @param custom_query_file
#   Puppet fileserver path to a file which contains your SQL queries, i.e. `dialup.conf`. This
#   option is intended to be a replacment for `query_file`, which requires separate deployment of the file. This
#   option allows you to specify a Puppet-managed custom `dialup.conf` which is installed and loaded automatically.
#   `query_file` must be left blank if you use `custom_query_file`.
# @param lifetime
#   Lifetime of an SQL socket. If you are having network issues such as TCP sessions expiring, you may need to set the socket
#   lifetime. If set to non-zero, any open connections will be closed `$lifetime` seconds after they were first opened.
# @param max_queries
#   Maximum number of queries used by an SQL socket. If you are having issues with SQL sockets lasting "too long", you can
#   limit the number of queries performed over one socket. After `$max_qeuries`, the socket will be closed. Use 0 for "no limit".
# @param ensure
# @param acct_table1
#   If you want both stop and start records logged to the same SQL table, leave this as is.  If you want them in
#   different tables, put the start table in `$acct_table1` and stop table in `$acct_table2`.
# @param acct_table2
#   If you want both stop and start records logged to the same SQL table, leave this as is.  If you want them in
#   different tables, put the start table in `$acct_table1` and stop table in `$acct_table2`.
# @param postauth_table
#   Table for storing data after authentication
# @param authcheck_table
# @param authreply_table
# @param groupcheck_table
# @param groupreply_table
# @param usergroup_table
#   Table to keep group info.
# @param deletestalesessions
#   Remove stale session if checkrad does not see a double login.
# @param sqltrace
#   Print all SQL statements when in debug mode (-x).
# @param sqltracefile
#   Location for SQL statements to be stored if `$sqltrace = yes`.
# @param connect_failure_retry_delay
#   Number of seconds to dely retrying on a failed database connection (per socket).
# @param nas_table
#   Table to keep radius client info.
# @param read_groups
#   If set to `yes` (default) we read the group tables. If set to `no` the user MUST have `Fall-Through = Yes` in the radreply table.
# @param port
#   TCP port to connect to the database.
# @param readclients
#   Set to `yes` to read radius clients from the database (`$nas_table`) Clients will ONLY be read on server startup. For performance
#   and security reasons, finding clients via SQL queries CANNOT be done "live" while the server is running.
# @param pool_start
#   Connections to create during module instantiation.
# @param pool_min
#   Minimum number of connnections to keep open.
# @param pool_spare
#   Spare connections to be left idle.
# @param pool_idle_timeout
#   Idle timeout (in seconds). A connection which is unused for this length of time will be closed.
# @param pool_connect_timeout
#   Connection timeout (in seconds). The maximum amount of time to wait for a new
#   connection to be established.
#
#   This parameter should only be set when using FreeRADIUS 3.1.x.
define freeradius::sql (
  Enum['mysql', 'mssql', 'oracle', 'postgresql'] $database,
  Freeradius::Password $password,
  Variant[Stdlib::Host, Stdlib::IP::Address] $server                                = 'localhost',
  Optional[String] $login                                                           = 'radius',
  Optional[String] $radius_db                                                       = 'radius',
  Variant[Freeradius::Integer, Enum["\${thread[pool].max_servers}"]] $num_sql_socks = "\${thread[pool].max_servers}",
  Optional[String] $query_file                                                      = "\${modconfdir}/\${.:name}/main/\${dialect}/queries.conf", # lint:ignore:140chars
  Optional[String] $custom_query_file                                               = undef,
  Optional[Integer] $lifetime                                                       = 0,
  Optional[Integer] $max_queries                                                    = 0,
  Freeradius::Ensure $ensure                                                        = present,
  Optional[String] $acct_table1                                                     = 'radacct',
  Optional[String] $acct_table2                                                     = 'radacct',
  Optional[String] $postauth_table                                                  = 'radpostauth',
  Optional[String] $authcheck_table                                                 = 'radcheck',
  Optional[String] $authreply_table                                                 = 'radreply',
  Optional[String] $groupcheck_table                                                = 'radgroupcheck',
  Optional[String] $groupreply_table                                                = 'radgroupreply',
  Optional[String] $usergroup_table                                                 = 'radusergroup',
  Freeradius::Boolean $deletestalesessions                                          = 'yes',
  Freeradius::Boolean $sqltrace                                                     = 'no',
  Optional[String] $sqltracefile                                                    = "\${logdir}/sqllog.sql",
  Optional[Integer] $connect_failure_retry_delay                                    = 60,
  Optional[String] $nas_table                                                       = 'nas',
  Freeradius::Boolean $read_groups                                                  = 'yes',
  Optional[Integer] $port                                                           = 3306,
  Freeradius::Boolean $readclients                                                  = 'no',
  Optional[Integer] $pool_start                                                     = 1,
  Optional[Integer] $pool_min                                                       = 1,
  Optional[Integer] $pool_spare                                                     = 1,
  Optional[Integer] $pool_idle_timeout                                              = 60,
  Optional[Float] $pool_connect_timeout                                             = undef,
) {
  $fr_basepath         = $freeradius::params::fr_basepath
  $fr_modulepath       = $freeradius::params::fr_modulepath
  $fr_group            = $freeradius::params::fr_group
  $fr_logpath          = $freeradius::params::fr_logpath
  $fr_moduleconfigpath = $freeradius::params::fr_moduleconfigpath

  # Warn if the user tries to set a FreeRADIUS 3.1.x specific parameter, and
  # we detect that they are not on (or not installing) a FreeRADIUS 3.1.x
  # then show them some errors
  # Additionally, if we are on FreeRADIUS 3.1.x then allow defaults for some
  # parameters, otherwise leave them set as specified when this define
  # is called.
  if $freeradius::fr_3_1 {
    if $pool_connect_timeout != undef {
      warning(@("WARN"/L)
          The `pool_connect_timeout` parameter requires FreeRADIUS 3.1.x, \
          i.e. the experimental branch. You are running \
          `${facts['freeradius_version']}`. In the future, attempting to set \
          it on this version may fail.
          |-WARN
      )
    }

    $resolved_pool_connect_timeout = $pool_connect_timeout ? {
      undef   => 3.0,
      default => $pool_connect_timeout,
    }
  } else {
    if $pool_connect_timeout != undef {
      fail(@("FAIL"/L)
          The `pool_connect_timeout` parameter requires FreeRADIUS 3.1.x, \
          i.e. the experimental branch. You are running \
          `${facts['freeradius_version']}`.
          |-FAIL
      )
    }
  }

  # Determine default location of query file
  $queryfile = "${fr_basepath}/sql/queries.conf"

  # Install custom query file
  if ($custom_query_file and $custom_query_file != '') {
    $custom_query_file_path = "${fr_moduleconfigpath}/${name}-queries.conf"

    freeradius::config { "${name}-queries.conf":
      source => $custom_query_file,
    }
  }

  # Generate a module config, based on sql.conf
  file { "freeradius mods-available/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/mods-available/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/sql.conf.erb'),
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
  file { "freeradius mods-enabled/${name}":
    ensure => link,
    path   => "${fr_modulepath}/${name}",
    target => "../mods-available/${name}",
  }

  # Install rotation for sqltrace if we are using it
  if ($sqltrace == 'yes') {
    logrotate::rule { 'sqltrace':
      path         => "${fr_logpath}/${sqltracefile}",
      rotate_every => 'week',
      rotate       => 1,
      create       => true,
      compress     => true,
      missingok    => true,
      postrotate   => "kill -HUP `cat ${freeradius::fr_pidfile}`",
    }
  }
}
