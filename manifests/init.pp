# Base class to install FreeRADIUS
class freeradius (
  $control_socket = false,
  $use_samba = true,
  $max_servers = '4096',
  $max_requests = '4096'
) inherits freeradius::params {
  if $use_samba {
    #    include samba

    # We don't want to create the radiusd user, just add it to the wbpriv group
    user { $fr_user:
      ensure  => present,
      uid     => '95',
      gid     => 'radiusd',
      groups  => 'wbpriv',
      require => Package[$fr_package, 'samba-winbind'],
    }
    
    $radiusd_service_requirements = [
      Exec['radiusd-config-test'],
      File['radiusd.conf'],
      User[$fr_user],
      Package[$fr_package],
      Service['winbind']
    ]

  } else {
    $radiusd_service_requirements = [
      Exec['radiusd-config-test'],
      File['radiusd.conf'],
      Package[$fr_package]
    ]
  }

  file { 'radiusd.conf':
    name    => "${fr_basepath}/radiusd.conf",
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    content => template('freeradius/radiusd.conf.erb'),
    require => Package[$fr_package],
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
    group   => 'radiusd',
    require => Package[$fr_package],
    notify  => Service[$fr_service],
  }

  # Set up concat policy file, as there is only one global policy
  # We also add standard header and footer
  concat { "${fr_basepath}/policy.conf":
    owner => 'root',
    group => 'radiusd',
    mode  => '0640',
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
    owner => 'root',
    group => 'radiusd',
    mode  => '0640',
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

  # Install FreeRADIUS packages from ResNet repo, which is newer than stock CentOS 
  package { 'freeradius':
    ensure => installed,
    name   => $fr_package,
  }

  package { [
    'freeradius-mysql',
    'freeradius-perl',
    'freeradius-utils',
  ]:
    ensure  => installed,
    require => Yumrepo['resnet'],
  }

  package { 'wpa_supplicant':
    ensure => installed,
  }

  # radiusd always tests its config before restarting the service, to avoid outage. If the config is not valid, the service
  # won't get restarted, and the puppet run will fail.
  service { 'radiusd':
    ensure     => running,
    name       => $fr_service,
    require    => $radiusd_service_requirements,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }

  # We don't want to create the radiusd user, just add it to the wbpriv group
  user { 'radiusd':
    ensure  => present,
    uid     => '95',
    gid     => 'radiusd',
    groups  => 'wbpriv',
    require => Package[$fr_package, 'samba-winbind'],
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
    command => "if \$programname == \'radiusd\' then /var/log/radius/radius.log\n&~",
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
    '/var/log/radius',
    '/var/log/radius/radacct',
  ]:
    mode    => '0750',
    require => Package[$fr_package],
  }

  file { '/var/log/radius/radius.log':
    owner   => 'radiusd',
    group   => 'radiusd',
    seltype => 'radiusd_log_t',
  }

  # Updated logrotate file to include radiusd-*.log
  file { '/etc/logrotate.d/radiusd':
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => 'puppet:///modules/freeradius/radiusd.logrotate',
    require => Package[$fr_package],
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
    command     => '/usr/bin/sudo /usr/sbin/radiusd -XC | /bin/grep \'Configuration appears to be OK.\' | /usr/bin/wc -l',
    returns     => 0,
    refreshonly => true,
    logoutput   => on_failure,
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
    group   => 'radiusd',
    require => Package[$fr_package],
    notify  => Service[$fr_service],
  }

  # Delete *.rpmnew and *.rpmsave files from the radius config dir because
  # radiusd stupidly reads these files in, and they break the config
  exec { 'delete-radius-rpmnew':
    command => "/bin/find ${fr_basepath} -name *.rpmnew -delete",
    onlyif  => "/bin/find ${fr_basepath} -name *.rpmnew | /bin/grep rpmnew",
  }
  exec { 'delete-radius-rpmsave':
    command => "/bin/find ${fr_basepath} -name *.rpmsave -delete",
    onlyif  => "/bin/find ${fr_basepath} -name *.rpmsave | /bin/grep rpmsave",
  }
}
