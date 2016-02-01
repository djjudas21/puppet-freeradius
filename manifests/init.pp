# Base class to install FreeRADIUS
class freeradius (
  $control_socket  = false,
  $max_servers     = '4096',
  $max_requests    = '4096',
  $mysql_support   = false,
  $perl_support    = false,
  $utils_support   = false,
  $ldap_support    = false,
  $wpa_supplicant  = false,
  $winbind_support = false,
  $syslog          = false,
) inherits freeradius::params {

  if ($::fr_version != 3) {
    fail('This module is only compatible with FreeRADIUS 3')
  }

  if $control_socket == true {
    warning('Use of the control_socket parameter in the freeradius class is deprecated. Please use the freeradius::control_socket class instead.')
  }

  file { 'radiusd.conf':
    name    => "${freeradius::fr_basepath}/radiusd.conf",
    mode    => '0640',
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
  ]:
    ensure  => directory,
    mode    => '0750',
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
    "${freeradius::fr_basepath}/sites-enabled",
    "${freeradius::fr_basepath}/sites-available",
    "${freeradius::fr_basepath}/instantiate",
  ]:
    ensure  => directory,
    purge   => true,
    recurse => true,
    mode    => '0750',
    owner   => 'root',
    group   => $freeradius::fr_group,
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }

  # Delete some modules which come bundled with the server that we
  # know break functionality out of the box with this config
  freeradius::module { 'eap':
    ensure => absent,
  }

  # Set up concat policy file, as there is only one global policy
  # We also add standard header and footer
  concat { "${freeradius::fr_basepath}/policy.conf":
    owner   => 'root',
    group   => $freeradius::fr_group,
    mode    => '0640',
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }
  concat::fragment { 'policy_header':
    target  => "${freeradius::fr_basepath}/policy.conf",
    content => "policy {\n",
    order   => 10,
  }
  concat::fragment { 'policy_footer':
    target  => "${freeradius::fr_basepath}/policy.conf",
    content => "}\n",
    order   => '99',
  }

  # Set up concat template file
  concat { "${freeradius::fr_basepath}/templates.conf":
    owner   => 'root',
    group   => $freeradius::fr_group,
    mode    => '0640',
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }
  concat::fragment { 'template_header':
    target => "${freeradius::fr_basepath}/templates.conf",
    source => 'puppet:///modules/freeradius/template.header',
    order  => '05',
  }
  concat::fragment { 'template_footer':
    target  => "${freeradius::fr_basepath}/templates.conf",
    content => "}\n",
    order   => '95',
  }


  # Set up concat proxy file
  concat { "${freeradius::fr_basepath}/proxy.conf":
    owner   => 'root',
    group   => $freeradius::fr_group,
    mode    => '0640',
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }
  concat::fragment { 'proxy_header':
    target  => "${freeradius::fr_basepath}/proxy.conf",
    content => "# Proxy config\n\n",
    order   => '05',
  }

  # Set up attribute filter file
  concat { "${freeradius::fr_modulepath}/attr_filter":
    owner   => 'root',
    group   => $freeradius::fr_group,
    mode    => '0640',
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
    notify  => Service[$freeradius::fr_service],
  }

  # Install default attribute filters
  concat::fragment { 'attr-default':
    target  => "${freeradius::fr_modulepath}/attr_filter",
    content => template('freeradius/attr_default.erb'),
    order   => 10,
  }

  # Install a slightly tweaked stock dictionary that includes
  # our custom dictionaries
  concat { "${freeradius::fr_basepath}/dictionary":
    owner   => 'root',
    group   => $freeradius::fr_group,
    mode    => '0640',
    require => [Package[$freeradius::fr_package], Group[$freeradius::fr_group]],
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

  # Install FreeRADIUS packages
  package { 'freeradius':
    ensure => installed,
    name   => $freeradius::fr_package,
  }
  if $mysql_support {
    package { 'freeradius-mysql':
      ensure => installed,
    }
  }
  if $perl_support {
    package { 'freeradius-perl':
      ensure => installed,
    }
  }
  if $utils_support {
    package { 'freeradius-utils':
      ensure => installed,
    }
  }
  if $ldap_support {
    package { 'freeradius-ldap':
      ensure => installed,
    }
  }
  if $wpa_supplicant {
    package { 'wpa_supplicant':
      ensure => installed,
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
  user { $freeradius::fr_user:
    ensure  => present,
    groups  => $winbind_support ? {
      true    => $freeradius::fr_wbpriv_user,
      default => undef,
    },
    require => Package[$freeradius::fr_package],
  }

  # We don't want to add the radiusd group but it must be defined
  # here so we can depend on it. WE depend on the FreeRADIUS
  # package to be sure that the group has been created.
  group { $freeradius::fr_group:
    ensure  => present,
    require => Package[$freeradius::fr_package]
  }

  # Install a few modules required on all FR installations
  # No content is specified, so we accept the package manager default
  # Defining them here prevents them from being purged
  freeradius::module  { 'always': }
  freeradius::module { 'detail': }
  freeradius::module { 'detail.log': }

  # Syslog rules
  if $syslog == true {
    rsyslog::snippet { '12-radiusd-log':
      content => "if \$programname == \'radiusd\' then ${freeradius::fr_logpath}/radius.log\n&~",
    }
  }

  # Make the radius log dir traversable
  file { [
    $freeradius::fr_logpath,
    "${freeradius::fr_logpath}/radacct",
  ]:
    mode    => '0750',
    require => Package[$freeradius::fr_package],
  }

  file { "${freeradius::fr_logpath}/radius.log":
    owner   => $freeradius::fr_user,
    group   => $freeradius::fr_group,
    seltype => 'radiusd_log_t',
    require => [Package[$freeradius::fr_package], User[$freeradius::fr_user], Group[$freeradius::fr_group]],
  }

  logrotate::rule { 'radacct':
    path          => "${freeradius::fr_logpath}/radacct/*/*.log",
    rotate_every  => 'day',
    rotate        => '7',
    create        => false,
    missingok     => true,
    compress      => true,
    postrotate    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
    sharedscripts => true,
  }

  logrotate::rule { 'checkrad':
    path          => "${freeradius::fr_logpath}/checkrad.log",
    rotate_every  => 'week',
    rotate        => '1',
    create        => true,
    missingok     => true,
    compress      => true,
    postrotate    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
    sharedscripts => true,
  }

  logrotate::rule { 'radiusd':
    path          => "${freeradius::fr_logpath}/radius*.log",
    rotate_every  => 'week',
    rotate        => '26',
    create        => true,
    missingok     => true,
    compress      => true,
    postrotate    => 'kill -HUP `cat /var/run/radiusd/radiusd.pid`',
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
  }

  # Generate global SSL parameters
  exec { 'random':
    command => "dd if=/dev/urandom of=${freeradius::fr_basepath}/certs/random count=10 >/dev/null 2>&1",
    creates => "${freeradius::fr_basepath}/certs/random",
    path    => '/bin',
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
    "${freeradius::fr_basepath}/sites-available/default",
    "${freeradius::fr_basepath}/sites-available/inner-tunnel",
    "${freeradius::fr_basepath}/clients.conf",
    "${freeradius::fr_basepath}/sql.conf",
  ]:
    content => "# FILE INTENTIONALLY BLANK\n",
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
