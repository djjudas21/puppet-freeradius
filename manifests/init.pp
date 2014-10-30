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
) inherits freeradius::params {

  file { 'radiusd.conf':
    name    => "${fr_basepath}/radiusd.conf",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/radiusd.conf.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  # Create various directories
  file { [
    "${fr_basepath}/clients.d",
    "${fr_basepath}/statusclients.d",
    $fr_basepath,
    "${fr_basepath}/instantiate",
    "${fr_basepath}/conf.d",
    "${fr_basepath}/attr.d",
    "${fr_basepath}/users.d",
    "${fr_basepath}/policy.d",
    "${fr_basepath}/dictionary.d",
    "${fr_basepath}/scripts",
    "${fr_basepath}/certs",
  ]:
    ensure  => directory,
    mode    => '0750',
    owner   => 'root',
    group   => $fr_group,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  # Set up concat policy file, as there is only one global policy
  # We also add standard header and footer
  concat { "${fr_basepath}/policy.conf":
    owner   => 'root',
    group   => $fr_group,
    mode    => '0640',
    require => [Package[$fr_package], Group[$fr_group]],
  }
  concat::fragment { 'policy_header':
    target  => "${fr_basepath}/policy.conf",
    content => "policy {\n",
    order   => 10,
  }
  concat::fragment { 'policy_footer':
    target  => "${fr_basepath}/policy.conf",
    content => "}\n",
    order   => '99',
  }

  # Install a slightly tweaked stock dictionary that includes
  # our custom dictionaries
  concat { "${fr_basepath}/dictionary":
    owner   => 'root',
    group   => $fr_group,
    mode    => '0640',
    require => [Package[$fr_package], Group[$fr_group]],
  }
  concat::fragment { 'dictionary_header':
    target => "${fr_basepath}/dictionary",
    source => 'puppet:///modules/freeradius/dictionary.header',
    order  => 10,
  }
  concat::fragment { 'dictionary_footer':
    target => "${fr_basepath}/dictionary",
    source => 'puppet:///modules/freeradius/dictionary.footer',
    order  => 90,
  }

  # Install FreeRADIUS packages
  package { 'freeradius':
    ensure => installed,
    name   => $fr_package,
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
      name   => $fr_wpa_supplicant,
    }
  }

  # radiusd always tests its config before restarting the service, to avoid outage. If the config is not valid, the service
  # won't get restarted, and the puppet run will fail.
  service { 'radiusd':
    ensure     => running,
    name       => $fr_service,
    require    => [Exec['radiusd-config-test'], File['radiusd.conf'], User[$fr_user], Package[$fr_package],],
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  # We don't want to create the radiusd user, just add it to the
  # wbpriv group if the user needs winbind support. We depend on
  # the FreeRADIUS package to be sure that the user has been created
  user { $fr_user:
    ensure  => present,
    groups  => $winbind_support ? {
      true    => $fr_wbpriv_user,
      default => undef,
    },
    require => Package[$fr_package],
  }

  # We don't want to add the radiusd group but it must be defined
  # here so we can depend on it. WE depend on the FreeRADIUS
  # package to be sure that the group has been created.
  group { $fr_group:
    ensure  => present,
    require => Package[$fr_package]
  }

  # Install a few modules required on all FR installations
  freeradius::module  { 'always':
    source  => 'puppet:///modules/freeradius/modules/always',
  }
  freeradius::module { 'detail':
    source  => 'puppet:///modules/freeradius/modules/detail',
  }
  freeradius::module { 'detail.log':
    source  => 'puppet:///modules/freeradius/modules/detail.log',
  }

  ::freeradius::module { 'logtosyslog':
    source => 'puppet:///modules/freeradius/modules/logtosyslog',
  }
  ::freeradius::module { 'logtofile':
    source => 'puppet:///modules/freeradius/modules/logtofile',
  }

  # Syslog rules
  syslog::rule { 'radiusd-log':
    command => "if \$programname == \'radiusd\' then ${fr_logpath}/radius.log\n&~",
    order   => '12',
  }


  # Install a couple of virtual servers needed on all FR installations
  if $control_socket == true {
    freeradius::site { 'control-socket':
      source  => 'puppet:///modules/freeradius/sites-enabled/control-socket',
    }
  }

  # Make the radius log dir traversable
  file { [
    $fr_logpath,
    "${fr_logpath}/radacct",
  ]:
    mode    => '0750',
    require => Package[$fr_package],
  }

  file { "${fr_logpath}/radius.log":
    owner   => $fr_user,
    group   => $fr_group,
    seltype => 'radiusd_log_t',
    require => [Package[$fr_package], User[$fr_user], Group[$fr_group]],
  }

  # Updated logrotate file to include radiusd-*.log
  file { '/etc/logrotate.d/radiusd':
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/radiusd.logrotate.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
  }

  # Generate global SSL parameters
  exec { 'dh':
    command => "openssl dhparam -out ${fr_basepath}/certs/dh 1024",
    creates => "${fr_basepath}/certs/dh",
    path    => '/usr/bin',
  }

  # Generate global SSL parameters
  exec { 'random':
    command => "dd if=/dev/urandom of=${fr_basepath}/certs/random count=10 >/dev/null 2>&1",
    creates => "${fr_basepath}/certs/random",
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
    "${fr_basepath}/sites-available/default",
    "${fr_basepath}/sites-available/inner-tunnel",
    "${fr_basepath}/proxy.conf",
    "${fr_basepath}/clients.conf",
  ]:
    content => "# FILE INTENTIONALLY BLANK\n",
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  # Delete *.rpmnew and *.rpmsave files from the radius config dir because
  # radiusd stupidly reads these files in, and they break the config
  # This should be fixed in FreeRADIUS 2.2.0
  # http://lists.freeradius.org/pipermail/freeradius-users/2012-October/063232.html
  # Only affects RPM-based systems
  if $::osfamily == 'RedHat' {
    exec { 'delete-radius-rpmnew':
      command => "find ${fr_basepath} -name *.rpmnew -delete",
      onlyif  => "find ${fr_basepath} -name *.rpmnew | grep rpmnew",
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    }
    exec { 'delete-radius-rpmsave':
      command => "find ${fr_basepath} -name *.rpmsave -delete",
      onlyif  => "find ${fr_basepath} -name *.rpmsave | grep rpmsave",
      path    => ['/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'],
    }
  }
}
