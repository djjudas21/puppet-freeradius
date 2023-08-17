# @summary Configure LDAP support for FreeRADIUS
#
# @param basedn
#   Unless overridden in another section, the dn from which all searches will start from.
# @param ensure
#   Whether the site should be present or not.
# @param server
#   Array of hostnames or IP addresses of the LDAP server(s). Note that this needs to match the name(s) in the LDAP
#   server certificate, if you're using ldaps.
# @param port
#   Port to connect to the LDAP server on.
# @param identity
#   LDAP account for searching the directory.
# @param password
#   Password for the `identity` account.
# @param sasl
#   SASL parameters to use for admin binds to the ldap server. This is a hash with 3 possible keys:
#   * `mech`: The SASL mechanism used.
#   * `proxy`: SASL authorizatino identity to proxy.
#   * `realm`: SASL realm (used for kerberos)
# @param valuepair_attribute
#   Generic valuepair attribute. If set, this attribute will be retrieved in addition to any mapped attributes.
# @param update
#   Array with mapping of LDAP directory attributes to RADIUS dictionary attributes.
# @param edir
#   Set to `yes` if you have eDirectory and want to use the universal password mechanisms.
# @param edir_autz
#   Set to `yes`if you want to bind as the user after retrieving the Cleartest-Password.
# @param user_base_dn
#   Where to start searching for users in the LDAP tree.
# @param user_filter
# @param user_sasl
#   SASL parameters to use for user binds to the ldap server. This is a hash with 3 possible keys:
#   * `mech`: The SASL mechanism used.
#   * `proxy`: SASL authorizatino identity to proxy.
#   * `realm`: SASL realm (used for kerberos)
# @param user_scope
#   Search scope for users.
# @param user_sort_by
#   Server side result sorting. A list of space delimited attributes to order the result set by.
# @param user_access_attribute
#   If this undefined, anyone is authorized.
#   If it is defined, the contents of this attribute determine whether or not the user is authorised.
# @param user_access_positive
#   Control whether the presence of `access_attribute` allows access or denys access.
# @param group_base_dn
#   Where to start searching for groups in the LDAP tree.
# @param group_filter
#   Filter for group objects.
# @param group_scope
#   Search scope for groups.
# @param group_name_attribute
#   Attribute that uniquely identifies a group.
# @param group_membership_filter
#   Filter to find group objects a user is member of.
#   That is, group objects with attributes that identify members (the inverse of `group_membership_attribute`).
# @param group_membership_attribute
#   The attribute in user objects which contain the namos or DNs of groups a user is a member of.
# @param group_cacheable_name
#   If `group_cacheable_name` or `group_cacheable_dn` are enabled, all group information for the user will be retrieved from the directory
#   and written to LDAP-Group attributes appropiaate for the instance of rlm_ldap.
# @param group_cacheable_dn
#   If `group_cacheable_name` or `group_cacheable_dn` are enabled, all group information for the user will be retrieved from the directory
#   and written to LDAP-Group attributes appropiaate for the instance of rlm_ldap.
# @param group_cache_attribute
#   Override the normal cache attribute (`<inst>-LDAP-Group` or `LDAP-Group` if using the default instance) and create a custom attribute.
# @param group_attribute
#   Override the normal group comparison attribute name (`<inst>-LDAP-Group` or `LDAP-Group` if using the default instance).
# @param profile_filter
#   Filter for RADIUS profile objects.
# @param profile_default
#   The default profile. This may be a DN or an attribute reference.
# @param profile_attribute
#   The LDAP attribute containing profile DNs to apply in addition to the default profile above.
# @param client_base_dn
#   Where to start searching for clients in the LDAP tree.
# @param client_filter
#   Filter to match client objects.
# @param client_scope
#   Search scope for clients.
# @param read_clients
#   Load clients on startup.
# @param dereference
#   Control under which situations LDAP aliases are followed.
# @param chase_referrals
#   With `rebind` control whether the server follows references returned by LDAP directory. Mostly used for AD compatibility.
# @param rebind
#   With `chase_referrals` control whether the server follows references returned by LDAP directory. Mostly used for AD compatibility.
# @param use_referral_credentials
#   On rebind, use the credentials from the rebind url instead of admin credentials.
#
#   This parameter should only be set when using FreeRADIUS 3.1.x.
# @param session_tracking
#   If `yes`, then include draft-wahl-ldap-session tracking controls.
#
#   This parameter should only be set when using FreeRADIUS 3.1.x.
# @param timeout
#   Number of seconds to wait for LDAP query to finish.
# @param timelimit
#   Seconds LDAP server has to process the query (server-side time limit).
# @param idle
#   Sets the idle time before keepalive probes are sent.
#
#   This option may not be supported by your LDAP library. If this configuration entry appears in the
#   output of `radiusd -X` then it is supported. Otherwise, it is unsupported and changing it will do nothing.
# @param probes
#   Sets the maximum number of keepalive probes TCP should send before dropping the connection.
#
#   This option may not be supported by your LDAP library. If this configuration entry appears in the
#   output of `radiusd -X` then it is supported. Otherwise, it is unsupported and changing it will do nothing.
# @param interval
#   Sets the interval in seconds between individual keepalive probes.
#
#   This option may not be supported by your LDAP library. If this configuration entry appears in the
#   output of `radiusd -X` then it is supported. Otherwise, it is unsupported and changing it will do nothing.
# @param ldap_debug
#   Debug flag for LDAP SDK.
# @param starttls
#   Set this to 'yes' to use TLS encrypted connections to the LDAP database by using the StartTLS extended operation.
#   The StartTLS operation is supposed to be used with normal ldap connections instead of using ldaps (port 636) connections
# @param cafile
#   Path to CA cert file for TLS
# @param capath
#   Path to CA cert files for TLS
# @param certfile
#   Path to cert file for TLS
# @param keyfile
#   Path to key file for TLS
# @param random_file
#   Random file used for TLS operations.
#   `undef` defaults to `'/dev/urandom'`.
# @param requirecert
#   Certificate Verification requirements. Choose from:
#   * `never` (do not even bother trying)
#   * `allow` (try, but don't fail if the certificate cannot be verified)
#   * `demand` (fail if the certificate does not verify)
#   * `hard`  (similar to `demand` but fails if TLS cannot negotiate)
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
# @param uses
#   How many times the connection can be used before being re-established. This is useful for things
#   like load balancers, which may exhibit sticky behaviour without it. `0` is unlimited.
# @param retry_delay
#   The number of seconds to wait after the server tries to open a connection, and fails.
# @param lifetime
#   The lifetime (in seconds) of the connection.
# @param idle_timeout
#   Idle timeout (in seconds). A connection which is unused for this length of time will be closed.
# @param connect_timeout
#   Connection timeout (in seconds). The maximum amount of time to wait for a new connection to be established.
#
#   This parameter should only be set when using FreeRADIUS 3.1.x.
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
) {
  $fr_package          = $freeradius::params::fr_package
  $fr_service          = $freeradius::params::fr_service
  $fr_modulepath       = $freeradius::params::fr_modulepath
  $fr_basepath         = $freeradius::params::fr_basepath
  $fr_group            = $freeradius::params::fr_group

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
  if $freeradius::fr_3_1 {
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
