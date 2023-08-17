# Base class to install FreeRADIUS
class freeradius (
  String $package_name,
  String $wpa_supplicant_package_name,
  String $service_name,
  Boolean $service_has_status,
  String $pidfile,
  String $basepath,
  String $raddbdir,
  String $guessversion,
  String $logpath,
  String $user,
  String $group,
  String $wbpriv_user,
  String $libdir,
  String $db_dir,
  String $radacctdir,
  Boolean $control_socket                                      = false,
  Integer $max_servers                                         = 4096,
  Integer $max_requests                                        = 4096,
  Integer $max_request_time                                    = 30,
  Boolean $mysql_support                                       = false,
  Boolean $pgsql_support                                       = false,
  Boolean $perl_support                                        = false,
  Boolean $utils_support                                       = false,
  Boolean $ldap_support                                        = false,
  Boolean $dhcp_support                                        = false,
  Boolean $krb5_support                                        = false,
  Boolean $wpa_supplicant                                      = false,
  Boolean $winbind_support                                     = false,
  Enum['files', 'syslog', 'stdout', 'stderr'] $log_destination = 'files',
  Boolean $syslog                                              = false,
  String $syslog_facility                                      = 'daemon',
  Freeradius::Boolean $log_auth                                = 'no',
  Boolean $preserve_mods                                       = true,
  Boolean $correct_escapes                                     = true,
  Boolean $manage_logpath                                      = true,
  Optional[String] $package_ensure                             = 'installed',
  String $version                                              = pick_default($facts['freeradius_maj_version'], $guessversion),
) {
  if $version !~ /^3/ {
    notify { 'This module is only compatible with FreeRADIUS 3.': }
  }

  # Default module dir
  $moduledir = $version ? {
    '2'       => 'modules',
    '3'       => 'mods-enabled',
    default   => 'modules',
  }

  # Default module path
  $modulepath = "${basepath}/${moduledir}"

  # Default module config dir
  $modconfigdir = $version ? {
    '2'       => 'conf.d',
    '3'       => 'mods-config',
    default   => 'conf.d',
  }

  # Default module config path
  $moduleconfigpath = "${basepath}/${modconfigdir}"

  # Guess if we are running FreeRADIUS 3.1.x
  if (
    ($package_ensure =~ /^3\.1\./) or
    ($facts['freeradius_version'] and $facts['freeradius_version'] =~ /^3\.1\./)
  ) {
    $fr_3_1 = true
  } else {
    $fr_3_1 = false
  }

  if $control_socket == true {
    warning(@(WARN/L)
      Use of the control_socket parameter in the freeradius class is deprecated. \
      Please use the freeradius::control_socket class instead.
      |-WARN
    )
  }

  # Always restart the service after every module operation
  Freeradius::Module {
    notify => Service[$service_name]
  }

  file { 'radiusd.conf':
    name    => "${basepath}/radiusd.conf",
    mode    => '0644',
    owner   => 'root',
    group   => $group,
    content => template('freeradius/radiusd.conf.erb'),
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Create various directories
  file { [
    "${basepath}/statusclients.d",
    $basepath,
    "${basepath}/conf.d",
    "${basepath}/attr.d",
    "${basepath}/users.d",
    "${basepath}/policy.d",
    "${basepath}/dictionary.d",
    "${basepath}/scripts",
    "${basepath}/mods-config",
    "${basepath}/mods-config/attr_filter",
    "${basepath}/mods-config/preprocess",
    "${basepath}/mods-config/sql",
    "${basepath}/sites-available",
    "${basepath}/mods-available",
  ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => $group,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Create these directories separately so we can set purge option
  # Anything in these dirs NOT managed by puppet will be removed!
  file { [
    "${basepath}/certs",
    "${basepath}/clients.d",
    "${basepath}/listen.d",
    "${basepath}/sites-enabled",
    "${basepath}/mods-enabled",
    "${basepath}/instantiate",
  ]:
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0755',
    owner   => 'root',
    group   => $group,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Preserve some stock modules
  if ($preserve_mods) {
    freeradius::module { [
      'always',
      'cache_eap',
      'chap',
      'detail',
      'detail.log',
      'digest',
      'dynamic_clients',
      'echo',
      'exec',
      'expiration',
      'expr',
      'files',
      'linelog',
      'logintime',
      'mschap',
      'ntlm_auth',
      'pap',
      'passwd',
      'preprocess',
      'radutmp',
      'realm',
      'replicate',
      'soh',
      'sradutmp',
      'unix',
      'unpack',
      'utf8',
    ]:
      preserve => true,
    }
  }

  # Set up concat policy file, as there is only one global policy
  # We also add standard header and footer
  concat { "${basepath}/policy.conf":
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$package_name], Group[$group]],
    notify         => Service[$service_name],
  }
  concat::fragment { 'policy_header':
    target  => "${basepath}/policy.conf",
    content => 'policy {',
    order   => 10,
  }
  concat::fragment { 'policy_footer':
    target  => "${basepath}/policy.conf",
    content => '}',
    order   => '99',
  }

  # Set up concat template file
  concat { "${basepath}/templates.conf":
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$package_name], Group[$group]],
    notify         => Service[$service_name],
  }
  concat::fragment { 'template_header':
    target => "${basepath}/templates.conf",
    source => 'puppet:///modules/freeradius/template.header',
    order  => '05',
  }
  concat::fragment { 'template_footer':
    target  => "${basepath}/templates.conf",
    content => '}',
    order   => '95',
  }

  # Set up concat proxy file
  concat { "${basepath}/proxy.conf":
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$package_name], Group[$group]],
    notify         => Service[$service_name],
  }
  concat::fragment { 'proxy_header':
    target  => "${basepath}/proxy.conf",
    content => '# Proxy config',
    order   => '05',
  }

  # Set up attribute filter file
  concat { "${basepath}/mods-available/attr_filter":
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$package_name], Group[$group]],
    notify         => Service[$service_name],
  }
  file { "${modulepath}/attr_filter":
    ensure => link,
    target => '../mods-available/attr_filter',
    notify => Service[$service_name],
  }

  # Install default attribute filters
  concat::fragment { 'attr-default':
    target  => "${basepath}/mods-available/attr_filter",
    content => template('freeradius/attr_default.erb'),
    order   => 10,
  }

  # Manage the file permissions for files defined in attr_filter
  file { [
    "${basepath}/mods-config/attr_filter/access_challenge",
    "${basepath}/mods-config/attr_filter/access_reject",
    "${basepath}/mods-config/attr_filter/accounting_response",
    "${basepath}/mods-config/attr_filter/post-proxy",
    "${basepath}/mods-config/attr_filter/pre-proxy",
  ]:
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Install a slightly tweaked stock dictionary that includes
  # our custom dictionaries
  concat { "${basepath}/dictionary":
    owner          => 'root',
    group          => $group,
    mode           => '0644',
    ensure_newline => true,
    require        => [Package[$package_name], Group[$group]],
  }
  concat::fragment { 'dictionary_header':
    target => "${basepath}/dictionary",
    source => 'puppet:///modules/freeradius/dictionary.header',
    order  => 10,
  }
  concat::fragment { 'dictionary_footer':
    target => "${basepath}/dictionary",
    source => 'puppet:///modules/freeradius/dictionary.footer',
    order  => 90,
  }

  # Install a huntgroups file
  concat { "${basepath}/mods-config/preprocess/huntgroups":
    owner          => 'root',
    group          => $group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$package_name], Group[$group]],
    notify         => Service[$service_name],
  }
  concat::fragment { 'huntgroups_header':
    target => "${basepath}/mods-config/preprocess/huntgroups",
    source => 'puppet:///modules/freeradius/huntgroups.header',
    order  => 10,
  }

  # Fix the permissions on the hints file
  file { "${basepath}/mods-config/preprocess/hints":
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    require => [Package[$package_name], Group[$group]],
  }

  # Install FreeRADIUS packages
  package { 'freeradius':
    ensure => $package_ensure,
    name   => $package_name,
  }
  if $mysql_support {
    package { 'freeradius-mysql':
      ensure => $package_ensure,
    }
  }
  if $pgsql_support {
    package { 'freeradius-postgresql':
      ensure => $package_ensure,
    }
  }
  if $perl_support {
    package { 'freeradius-perl':
      ensure => $package_ensure,
    }
  }
  if $utils_support {
    package { 'freeradius-utils':
      ensure => $package_ensure,
    }
  }
  if $ldap_support {
    package { 'freeradius-ldap':
      ensure => $package_ensure,
    }
  }
  if $dhcp_support {
    package { 'freeradius-dhcp':
      ensure => $package_ensure,
    }
  }
  if $krb5_support {
    package { 'freeradius-krb5':
      ensure => $package_ensure,
    }
  }
  if $wpa_supplicant {
    package { 'wpa_supplicant':
      ensure => $package_ensure,
      name   => $wpa_supplicant_package_name,
    }
  }

  # radiusd always tests its config before restarting the service, to avoid outage. If the config is not valid, the service
  # won't get restarted, and the puppet run will fail.
  service { $service_name:
    ensure     => running,
    name       => $service_name,
    require    => [Exec['radiusd-config-test'], File['radiusd.conf'], User[$user], Package[$package_name],],
    enable     => true,
    hasstatus  => $service_has_status,
    hasrestart => true,
  }

  # We don't want to create the radiusd user, just add it to the
  # wbpriv group if the user needs winbind support. We depend on
  # the FreeRADIUS package to be sure that the user has been created
  $user_group = $winbind_support ? {
    true    => $wbpriv_user,
    default => undef,
  }
  user { $user:
    ensure  => present,
    groups  => $user_group,
    require => Package[$package_name],
  }

  # We don't want to add the radiusd group but it must be defined
  # here so we can depend on it. WE depend on the FreeRADIUS
  # package to be sure that the group has been created.
  group { $group:
    ensure  => present,
    require => Package[$package_name],
  }

  # Syslog rules
  if $syslog == true {
    rsyslog::snippet { '12-radiusd-log':
      content => "if \$programname == \'radiusd\' then ${logpath}/radius.log\n\\&\\~",
    }
  }

  if $manage_logpath {
    # Make the radius log dir traversable
    file { [
      $logpath,
      "${logpath}/radacct",
    ]:
      group   => $group,
      mode    => '0750',
      owner   => $user,
      require => Package[$package_name],
    }

    file { "${logpath}/radius.log":
      owner   => $user,
      group   => $group,
      seltype => 'radiusd_log_t',
      require => [Package[$package_name], User[$user], Group[$group]],
    }
  }

  logrotate::rule { 'radacct':
    path          => "${logpath}/radacct/*/*.log",
    rotate_every  => 'day',
    rotate        => 7,
    create        => false,
    missingok     => true,
    compress      => true,
    postrotate    => "kill -HUP `cat ${pidfile}`",
    sharedscripts => true,
  }

  logrotate::rule { 'checkrad':
    path          => "${logpath}/checkrad.log",
    rotate_every  => 'week',
    rotate        => 1,
    create        => true,
    missingok     => true,
    compress      => true,
    postrotate    => "kill -HUP `cat ${pidfile}`",
    sharedscripts => true,
  }

  logrotate::rule { 'radiusd':
    path          => "${logpath}/radius*.log",
    rotate_every  => 'week',
    rotate        => 26,
    create        => true,
    missingok     => true,
    compress      => true,
    postrotate    => "kill -HUP `cat ${pidfile}`",
    sharedscripts => true,
  }

  # Placeholder resource for dh and random as they are dynamically generated, so they
  # exist in the catalogue and don't get purged
  file { ["${basepath}/certs/dh", "${basepath}/certs/random"]:
    require => Exec['dh', 'random'],
  }

  # Generate global SSL parameters
  exec { 'dh':
    command => "openssl dhparam -out ${basepath}/certs/dh 1024",
    creates => "${basepath}/certs/dh",
    path    => '/usr/bin',
    require => File["${basepath}/certs"],
  }

  # Generate global SSL parameters
  exec { 'random':
    command => "dd if=/dev/urandom of=${basepath}/certs/random count=10 >/dev/null 2>&1",
    creates => "${basepath}/certs/random",
    path    => '/bin',
    require => File["${basepath}/certs"],
  }

  # This exec tests the radius config and fails if it's bad
  # It isn't run every time puppet runs, but only when freeradius is to be restarted
  exec { 'radiusd-config-test':
    command     => 'sudo radiusd -XC | grep \'Configuration appears to be OK.\' | wc -l',
    returns     => 0,
    refreshonly => true,
    logoutput   => on_failure,
    path        => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
  }

  # Blank a couple of default files that will break our config. This is more effective than deleting them
  # as they won't get overwritten when FR is upgraded from RPM, whereas missing files are replaced.
  file { [
    "${basepath}/clients.conf",
    "${basepath}/sql.conf",
  ]:
    content => '# FILE INTENTIONALLY BLANK',
    mode    => '0644',
    owner   => 'root',
    group   => $group,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Delete *.rpmnew and *.rpmsave files from the radius config dir because
  # radiusd stupidly reads these files in, and they break the config
  # This should be fixed in FreeRADIUS 2.2.0
  # http://lists.freeradius.org/pipermail/freeradius-users/2012-October/063232.html
  # Only affects RPM-based systems
  if $::osfamily == 'RedHat' {
    exec { 'delete-radius-rpmnew':
      command => "find ${basepath} -name *.rpmnew -delete",
      onlyif  => "find ${basepath} -name *.rpmnew | grep rpmnew",
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    }
    exec { 'delete-radius-rpmsave':
      command => "find ${basepath} -name *.rpmsave -delete",
      onlyif  => "find ${basepath} -name *.rpmsave | grep rpmsave",
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    }
  }
}
