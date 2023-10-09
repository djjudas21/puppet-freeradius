# Configure SQL support for FreeRADIUS
define freeradius::sql (
  Enum['mysql', 'mssql', 'oracle', 'postgresql'] $database,
  Freeradius::Password $password,
  Variant[Stdlib::Host, Stdlib::IP::Address] $server                                = 'localhost',
  Optional[String] $login                                                           = 'radius',
  Optional[String] $radius_db                                                       = 'radius',
  Variant[Freeradius::Integer, Enum["\${thread[pool].max_servers}"]] $num_sql_socks = "\${thread[pool].max_servers}",
  Optional[String] $query_file                                                      = "\${modconfdir}/\${.:name}/main/\${dialect}/queries.conf",
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
  $fr_basepath         = $::freeradius::params::fr_basepath
  $fr_modulepath       = $::freeradius::params::fr_modulepath
  $fr_group            = $::freeradius::params::fr_group
  $fr_logpath          = $::freeradius::params::fr_logpath
  $fr_moduleconfigpath = $::freeradius::params::fr_moduleconfigpath

  # Warn if the user tries to set a FreeRADIUS 3.1.x specific parameter, and
  # we detect that they are not on (or not installing) a FreeRADIUS 3.1.x
  # then show them some errors
  # Additionally, if we are on FreeRADIUS 3.1.x then allow defaults for some
  # parameters, otherwise leave them set as specified when this define
  # is called.
  if $::freeradius::fr_3_1 {
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

    ::freeradius::config { "${name}-queries.conf":
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
