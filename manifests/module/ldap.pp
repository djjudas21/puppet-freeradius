# Configure LDAP support for FreeRADIUS
define freeradius::module::ldap (
  String $basedn,
  Freeradius::Ensure $ensure                                         = 'present',
  Array[String] $server                                               = ['localhost'],
  Integer $port                                                       = 389,
  Optional[String] $identity                                          = undef,
  Optional[Freeradius::Password] $password                            = undef,
  Optional[Freeradius::Sasl] $sasl                                    = {},
  Optional[String] $valuepair_attribute                               = undef,
  Optional[Array[String]] $update                                     = undef,
  Optional[Freeradius::Boolean] $edir                                 = undef,
  Optional[Freeradius::Boolean] $edir_autz                            = undef,
  String $user_base_dn                                                = "\${..base_dn}",
  String $user_filter                                                 = '(uid=%{%{Stripped-User-Name}:-%{User-Name}})',
  Optional[Freeradius::Sasl] $user_sasl                               = {},
  Optional[Freeradius::Scope] $user_scope                             = undef,
  Optional[String] $user_sort_by                                      = undef,
  Optional[String] $user_access_attribute                             = undef,
  Optional[Freeradius::Boolean] $user_access_positive                 = undef,
  String $group_base_dn                                               = "\${..base_dn}",
  String $group_filter                                                = '(objectClass=posixGroup)',
  Optional[Freeradius::Scope] $group_scope                            = undef,
  Optional[String] $group_name_attribute                              = undef,
  Optional[String] $group_membership_filter                           = undef,
  String $group_membership_attribute                                  = 'memberOf',
  Optional[Freeradius::Boolean] $group_cacheable_name                 = undef,
  Optional[Freeradius::Boolean] $group_cacheable_dn                   = undef,
  Optional[String] $group_cache_attribute                             = undef,
  Optional[String] $group_attribute                                   = undef,
  Optional[String] $profile_filter                                    = undef,
  Optional[String] $profile_default                                   = undef,
  Optional[String] $profile_attribute                                 = undef,
  String $client_base_dn                                              = "\${..base_dn}",
  String $client_filter                                               = '(objectClass=radiusClient)',
  Optional[Freeradius::Boolean] $client_scope                         = undef,
  Optional[Freeradius::Boolean] $read_clients                         = undef,
  Optional[Enum['never','searching','finding','always']] $dereference = undef,
  Freeradius::Boolean $chase_referrals                                = 'yes',
  Freeradius::Boolean $rebind                                         = 'yes',
  Optional[Freeradius::Boolean] $use_referral_credentials             = undef,
  Optional[Freeradius::Boolean] $session_tracking                     = undef,
  Integer $timeout                                                    = 10,
  Integer $timelimit                                                  = 3,
  Integer $idle                                                       = 60,
  Integer $probes                                                     = 3,
  Integer $interval                                                   = 3,
  String $ldap_debug                                                  = '0x0028',
  Freeradius::Boolean $starttls                                       = 'no',
  Optional[String] $cafile                                            = undef,
  Optional[String] $capath                                            = undef,
  Optional[String] $certfile                                          = undef,
  Optional[String] $keyfile                                           = undef,
  Optional[String] $random_file                                       = undef,
  Enum['never','allow','demand','hard'] $requirecert                  = 'allow',
  Freeradius::Integer $start                                          = "\${thread[pool].start_servers}",
  Freeradius::Integer $min                                            = "\${thread[pool].min_spare_servers}",
  Freeradius::Integer $max                                            = "\${thread[pool].max_servers}",
  Freeradius::Integer $spare                                          = "\${thread[pool].max_spare_servers}",
  Integer $uses                                                       = 0,
  Integer $retry_delay                                                = 30,
  Integer $lifetime                                                   = 0,
  Integer $idle_timeout                                               = 60,
  Optional[Float] $connect_timeout                                    = undef,
  Integer $net_timeout                                                = 1,

) {
  $fr_package          = $::freeradius::params::fr_package
  $fr_service          = $::freeradius::params::fr_service
  $fr_modulepath       = $::freeradius::params::fr_modulepath
  $fr_basepath         = $::freeradius::params::fr_basepath
  $fr_group            = $::freeradius::params::fr_group

  # Validate our inputs
  # FR3.0 format server = 'ldap1.example.com, ldap1.example.com, ldap1.example.com'
  # FR3.1 format server = 'ldap1.example.com'
  #              server = 'ldap2.example.com'
  #              server = 'ldap3.example.com'
  $serverconcatarray = $facts['freeradius_version'] ? {
    /^3\.0\./ => any2array(join($server, ',')),
    default   => $server,
  }

  # Warn if the user tries to set a FreeRADIUS 3.1.x specific parameter, and
  # we detect that they are not on (or not installing) a FreeRADIUS 3.1.x
  # then show them some errors
  # Additionally, if we are on FreeRADIUS 3.1.x then allow defaults for some
  # parameters, otherwise leave them set as specified when this define
  # is called.
  if $::freeradius::fr_3_1 {
    if $connect_timeout != undef {
      warning(@("WARN"/L)
        The `connect_timeout` parameter requires FreeRADIUS 3.1.x, i.e. the \
        experimental branch. You are running `${facts['freeradius_version']}`. \
        In the future, attempting to set it on this version may fail.
        |-WARN
      )
    }

    if $session_tracking != undef {
      warning(@("WARN"/L)
        The `session_tracking` parameter requires FreeRADIUS 3.1.x, i.e. the \
        experimental branch. You are running `${facts['freeradius_version']}`. \
        In the future, attempting to set it on this version may fail.
        |-WARN
      )
    }

    if $use_referral_credentials != undef {
      warning(@("WARN"/L)
        The `use_referral_credentials` parameter requires FreeRADIUS 3.1.x, \
        i.e. the experimental branch. You are running \
        `${facts['freeradius_version']}`. In the future, attempting to set \
        it on this version may fail.
        |-WARN
      )
    }

    $resolved_connect_timeout = $connect_timeout ? {
      undef   => 3.0,
      default => $connect_timeout,
    }

    $resolved_session_tracking = $session_tracking

    $resolved_use_referral_credentials = $use_referral_credentials ? {
      undef   => 'no',
      default => $use_referral_credentials,
    }
  } else {
    if $connect_timeout != undef {
      fail(@("FAIL"/L)
        The `connect_timeout` parameter requires FreeRADIUS 3.1.x, i.e. the \
        experimental branch. You are running `${facts['freeradius_version']}`.
        |-FAIL
      )
    }

    if $session_tracking != undef {
      fail(@("FAIL"/L)
        The `session_tracking` parameter requires FreeRADIUS 3.1.x, i.e. the \
        experimental branch. You are running `${facts['freeradius_version']}`.
        |-FAIL
      )
    }

    if $use_referral_credentials != undef {
      fail(@("FAIL"/L)
        The `use_referral_credentials` parameter requires FreeRADIUS 3.1.x, \
        i.e. the experimental branch. You are running \
        `${facts['freeradius_version']}`.
        |-FAIL
      )
    }
  }

  # Generate a module config, based on ldap.conf
  file { "freeradius mods-available/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/mods-available/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/ldap.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
  file { "freeradius mods-enabled/${name}":
    ensure => link,
    path   => "${fr_modulepath}/${name}",
    target => "../mods-available/${name}",
  }
}
