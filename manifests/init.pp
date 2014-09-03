# Base class to install FreeRADIUS
class freeradius (
  $control_socket = false,
) {
  include samba
  include nagios::plugins::radius

  file { 'radiusd.conf':
    name    => '/etc/raddb/radiusd.conf',
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => 'puppet:///modules/freeradius/radiusd.conf',
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }

  # Wipe out static clients.conf as we will be using clients.d
  file { 'clients.conf':
    name    => '/etc/raddb/clients.conf',
    mode    => '0644',
    owner   => 'root',
    group   => 'radiusd',
    content => "# FILE INTENTIONALLY BLANK\n",
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }

  # Create various directories
  file { [
    '/etc/raddb/clients.d',
    '/etc/raddb/statusclients.d',
    '/etc/raddb',
    '/etc/raddb/instantiate',
    '/etc/raddb/conf.d',
    '/etc/raddb/attr.d',
    '/etc/raddb/users.d',
    '/etc/raddb/policy.d',
    '/etc/raddb/scripts',
    '/etc/raddb/certs',
  ]:
    ensure  => directory,
    mode    => '0750',
    owner   => 'root',
    group   => 'radiusd',
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }

  # Set up concat policy file, as there is only one global policy
  # We also add standard header and footer
  concat { '/etc/raddb/policy.conf':
    owner => 'root',
    group => 'radiusd',
    mode  => '0640',
  }
  concat::fragment { 'policy_header':
    target  => '/etc/raddb/policy.conf',
    content => "policy {\n",
    order   => 10,
  }
  concat::fragment { 'policy_footer':
    target  => '/etc/raddb/policy.conf',
    content => "}\n",
    order   => '99',
  }

  # Define the realms for which we are authoritative
  file { 'proxy.conf':
#    ensure  => absent,
    name    => '/etc/raddb/proxy.conf',
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
#    source  => 'puppet:///modules/freeradius/proxy.conf',
    content => '',
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }

  # Install FreeRADIUS packages from ResNet repo, which is newer than stock CentOS 
  package { [ 
    'freeradius',
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
    name       => $::operatingsystem ? {
      /CentOS|Scientific|Fedora/ => 'radiusd',
      /Ubuntu|Debian/            => 'freeradius',
      default                    => 'radiusd',
    },
    require    => [
      Exec['radiusd-config-test'],
      File['radiusd.conf'],
      User['radiusd'],
      Package['freeradius'],
      Service['winbind']
    ],
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
    require => Package['freeradius', 'samba-winbind'],
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
    require => Package['freeradius'],
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
    require => Package['freeradius'],
  }

  # Generate global SSL parameters
  exec { 'dh':
    command => 'openssl dhparam -out /etc/raddb/certs/dh 1024',
    creates => '/etc/raddb/certs/dh',
    path    => '/usr/bin',
  }

  # Generate global SSL parameters
  exec { 'random':
    command => 'dd if=/dev/urandom of=/etc/raddb/certs/random count=10 >/dev/null 2>&1',
    creates => '/etc/raddb/certs/random',
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
    '/etc/raddb/sites-available/default',
    '/etc/raddb/sites-available/inner-tunnel'
  ]:
    content => "# FILE INTENTIONALLY BLANK\n",
  }

  # Delete *.rpmnew and *.rpmsave files from the radius config dir because
  # radiusd stupidly reads these files in, and they break the config
  exec { 'delete-radius-rpmnew':
    command => '/bin/find /etc/raddb -name *.rpmnew -delete',
    onlyif  => '/bin/find /etc/raddb -name *.rpmnew | /bin/grep rpmnew',
  }
  exec { 'delete-radius-rpmsave':
    command => '/bin/find /etc/raddb -name *.rpmsave -delete',
    onlyif  => '/bin/find /etc/raddb -name *.rpmsave | /bin/grep rpmsave',
  }
}
