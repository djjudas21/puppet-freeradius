# Base class to install FreeRADIUS
class freeradius (
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
  String $radacctdir                                           = $freeradius::params::radacctdir,
) inherits freeradius::params {
  if $freeradius::fr_version !~ /^3/ {
    notify { 'This module is only compatible with FreeRADIUS 3.': }
  }

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
    notify => Service[$freeradius::fr_service]
  }

  file { 'radiusd.conf':
    name    => "${freeradius::fr_basepath}/radiusd.conf",
    mode    => '0644',
    owner   => 'root',
    group   => $freeradius::fr_group,
    content => template('freeradius/radiusd.conf.erb'),
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }

  # Create various directories
  file { [
    "${freeradius::fr_basepath}/statusclients.d",
    $freeradius::fr_basepath,
    "${freeradius::fr_basepath}/conf.d",
    "${freeradius::fr_basepath}/attr.d",
    "${freeradius::fr_basepath}/users.d",
    "${freeradius::fr_basepath}/policy.d",
    "${freeradius::fr_basepath}/dictionary.d",
    "${freeradius::fr_basepath}/scripts",
    "${freeradius::fr_basepath}/mods-config",
    "${freeradius::fr_basepath}/mods-config/attr_filter",
    "${freeradius::fr_basepath}/mods-config/preprocess",
    "${freeradius::fr_basepath}/mods-config/sql",
    "${freeradius::fr_basepath}/sites-available",
    "${freeradius::fr_basepath}/mods-available",
  ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => $freeradius::fr_group,
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }

  # Create these directories separately so we can set purge option
  # Anything in these dirs NOT managed by puppet will be removed!
  file { [
    "${freeradius::fr_basepath}/certs",
    "${freeradius::fr_basepath}/clients.d",
    "${freeradius::fr_basepath}/listen.d",
    "${freeradius::fr_basepath}/sites-enabled",
    "${freeradius::fr_basepath}/mods-enabled",
    "${freeradius::fr_basepath}/instantiate",
  ]:
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0755',
    owner   => 'root',
    group   => $freeradius::fr_group,
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
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
  concat { "${freeradius::fr_basepath}/policy.conf":
    owner          => 'root',
    group          => $freeradius::fr_group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify         => Service[$freeradius::fr_service],
  }
  concat::fragment { 'policy_header':
    target  => "${freeradius::fr_basepath}/policy.conf",
    content => 'policy {',
    order   => 10,
  }
  concat::fragment { 'policy_footer':
    target  => "${freeradius::fr_basepath}/policy.conf",
    content => '}',
    order   => '99',
  }

  # Set up concat template file
  concat { "${freeradius::fr_basepath}/templates.conf":
    owner          => 'root',
    group          => $freeradius::fr_group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify         => Service[$freeradius::fr_service],
  }
  concat::fragment { 'template_header':
    target => "${freeradius::fr_basepath}/templates.conf",
    source => 'puppet:///modules/freeradius/template.header',
    order  => '05',
  }
  concat::fragment { 'template_footer':
    target  => "${freeradius::fr_basepath}/templates.conf",
    content => '}',
    order   => '95',
  }

  # Set up concat proxy file
  concat { "${freeradius::fr_basepath}/proxy.conf":
    owner          => 'root',
    group          => $freeradius::fr_group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify         => Service[$freeradius::fr_service],
  }
  concat::fragment { 'proxy_header':
    target  => "${freeradius::fr_basepath}/proxy.conf",
    content => '# Proxy config',
    order   => '05',
  }

  # Set up attribute filter file
  concat { "${freeradius::fr_basepath}/mods-available/attr_filter":
    owner          => 'root',
    group          => $freeradius::fr_group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify         => Service[$freeradius::fr_service],
  }
  file { "${freeradius::fr_modulepath}/attr_filter":
    ensure => link,
    target => '../mods-available/attr_filter',
    notify => Service[$freeradius::fr_service],
  }

  # Install default attribute filters
  concat::fragment { 'attr-default':
    target  => "${freeradius::fr_basepath}/mods-available/attr_filter",
    content => template('freeradius/attr_default.erb'),
    order   => 10,
  }

  # Manage the file permissions for files defined in attr_filter
  file { [
    "${freeradius::fr_basepath}/mods-config/attr_filter/access_challenge",
    "${freeradius::fr_basepath}/mods-config/attr_filter/access_reject",
    "${freeradius::fr_basepath}/mods-config/attr_filter/accounting_response",
    "${freeradius::fr_basepath}/mods-config/attr_filter/post-proxy",
    "${freeradius::fr_basepath}/mods-config/attr_filter/pre-proxy",
  ]:
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => $freeradius::fr_group,
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }

  # Install a slightly tweaked stock dictionary that includes
  # our custom dictionaries
  concat { "${freeradius::fr_basepath}/dictionary":
    owner          => 'root',
    group          => $freeradius::fr_group,
    mode           => '0644',
    ensure_newline => true,
    require        => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
  }
  concat::fragment { 'dictionary_header':
    target => "${freeradius::fr_basepath}/dictionary",
    source => 'puppet:///modules/freeradius/dictionary.header',
    order  => 10,
  }
  concat::fragment { 'dictionary_footer':
    target => "${freeradius::fr_basepath}/dictionary",
    source => 'puppet:///modules/freeradius/dictionary.footer',
    order  => 90,
  }

  # Install a huntgroups file
  concat { "${freeradius::fr_basepath}/mods-config/preprocess/huntgroups":
    owner          => 'root',
    group          => $freeradius::fr_group,
    mode           => '0640',
    ensure_newline => true,
    require        => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify         => Service[$freeradius::fr_service],
  }
  concat::fragment { 'huntgroups_header':
    target => "${freeradius::fr_basepath}/mods-config/preprocess/huntgroups",
    source => 'puppet:///modules/freeradius/huntgroups.header',
    order  => 10,
  }

  # Fix the permissions on the hints file
  file { "${freeradius::fr_basepath}/mods-config/preprocess/hints":
    ensure  => 'present',
    mode    => '0640',
    owner   => 'root',
    group   => $freeradius::fr_group,
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
  }

  # Install FreeRADIUS packages
  package { 'freeradius':
    ensure => $package_ensure,
    name   => $freeradius::fr_package,
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
      name   => $freeradius::fr_wpa_supplicant,
    }
  }

  # radiusd always tests its config before restarting the service, to avoid outage. If the config is not valid, the service
  # won't get restarted, and the puppet run will fail.
  service { $freeradius::fr_service:
    ensure     => running,
    name       => $freeradius::fr_service,
    require    => [Exec['radiusd-config-test'], File['radiusd.conf'], User[$freeradius::fr_user], Package[$freeradius::fr_package],],
    enable     => true,
    hasstatus  => $freeradius::fr_service_has_status,
    hasrestart => true,
  }

  # We don't want to create the radiusd user, just add it to the
  # wbpriv group if the user needs winbind support. We depend on
  # the FreeRADIUS package to be sure that the user has been created
  $fr_user_group = $winbind_support ? {
    true    => $freeradius::fr_wbpriv_user,
    default => undef,
  }
  user { $freeradius::fr_user:
    ensure  => present,
    groups  => $fr_user_group,
    require => Package[$freeradius::fr_package],
  }

  # We don't want to add the radiusd group but it must be defined
  # here so we can depend on it. WE depend on the FreeRADIUS
  # package to be sure that the group has been created.
  group { $freeradius::fr_group:
    ensure  => present,
    require => Package[$freeradius::fr_package],
  }

  # Syslog rules
  if $syslog == true {
    rsyslog::snippet { '12-radiusd-log':
      content => "if \$programname == \'radiusd\' then ${freeradius::fr_logpath}/radius.log\n\\&\\~",
    }
  }

  if $manage_logpath {
    # Make the radius log dir traversable
    file { [
      $freeradius::fr_logpath,
      "${freeradius::fr_logpath}/radacct",
    ]:
      group   => $freeradius::fr_group,
      mode    => '0750',
      owner   => $freeradius::fr_user,
      require => Package[$freeradius::fr_package],
    }

    file { "${freeradius::fr_logpath}/radius.log":
      owner   => $freeradius::fr_user,
      group   => $freeradius::fr_group,
      seltype => 'radiusd_log_t',
      require => [Package[$freeradius::fr_package], User[$freeradius::fr_user], Group[$freeradius::fr_group]],
    }
  }

  logrotate::rule { 'radacct':
    path          => "${freeradius::fr_logpath}/radacct/*/*.log",
    rotate_every  => 'day',
    rotate        => 7,
    create        => false,
    missingok     => true,
    compress      => true,
    postrotate    => "kill -HUP `cat ${freeradius::fr_pidfile}`",
    sharedscripts => true,
  }

  logrotate::rule { 'checkrad':
    path          => "${freeradius::fr_logpath}/checkrad.log",
    rotate_every  => 'week',
    rotate        => 1,
    create        => true,
    missingok     => true,
    compress      => true,
    postrotate    => "kill -HUP `cat ${freeradius::fr_pidfile}`",
    sharedscripts => true,
  }

  logrotate::rule { 'radiusd':
    path          => "${freeradius::fr_logpath}/radius*.log",
    rotate_every  => 'week',
    rotate        => 26,
    create        => true,
    missingok     => true,
    compress      => true,
    postrotate    => "kill -HUP `cat ${freeradius::fr_pidfile}`",
    sharedscripts => true,
  }

  # Placeholder resource for dh and random as they are dynamically generated, so they
  # exist in the catalogue and don't get purged
  file { ["${freeradius::fr_basepath}/certs/dh", "${freeradius::fr_basepath}/certs/random"]:
    require => Exec['dh', 'random'],
  }

  # Generate global SSL parameters
  exec { 'dh':
    command => "openssl dhparam -out ${freeradius::fr_basepath}/certs/dh 1024",
    creates => "${freeradius::fr_basepath}/certs/dh",
    path    => '/usr/bin',
    require => File["${freeradius::fr_basepath}/certs"],
  }

  # Generate global SSL parameters
  exec { 'random':
    command => "dd if=/dev/urandom of=${freeradius::fr_basepath}/certs/random count=10 >/dev/null 2>&1",
    creates => "${freeradius::fr_basepath}/certs/random",
    path    => '/bin',
    require => File["${freeradius::fr_basepath}/certs"],
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
    "${freeradius::fr_basepath}/clients.conf",
    "${freeradius::fr_basepath}/sql.conf",
  ]:
    content => '# FILE INTENTIONALLY BLANK',
    mode    => '0644',
    owner   => 'root',
    group   => $freeradius::fr_group,
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }

  # Delete *.rpmnew and *.rpmsave files from the radius config dir because
  # radiusd stupidly reads these files in, and they break the config
  # This should be fixed in FreeRADIUS 2.2.0
  # http://lists.freeradius.org/pipermail/freeradius-users/2012-October/063232.html
  # Only affects RPM-based systems
  if $::osfamily == 'RedHat' {
    exec { 'delete-radius-rpmnew':
      command => "find ${freeradius::fr_basepath} -name *.rpmnew -delete",
      onlyif  => "find ${freeradius::fr_basepath} -name *.rpmnew | grep rpmnew",
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    }
    exec { 'delete-radius-rpmsave':
      command => "find ${freeradius::fr_basepath} -name *.rpmsave -delete",
      onlyif  => "find ${freeradius::fr_basepath} -name *.rpmsave | grep rpmsave",
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    }
  }
}
