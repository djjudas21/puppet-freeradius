# Configure LDAP support for FreeRADIUS
define freeradius::ldap (
  $identity,
  $password,
  $basedn,
  $server      = ['localhost'],
  $port        = 389,
  $uses        = 0,
  $idle        = 60,
  $probes      = 3,
  $interval    = 3,
  $timeout     = 10,
  $start       = '${thread[pool].start_servers}',
  $min         = '${thread[pool].min_spare_servers}',
  $max         = '${thread[pool].max_servers}',
  $spare       = '${thread[pool].max_spare_servers}',
  $ensure      = 'present',
  $starttls    = 'no',
  $cafile      = undef,
  $certfile    = undef,
  $keyfile     = undef,
  $requirecert = 'allow',
) {
  $fr_package          = $::freeradius::params::fr_package
  $fr_service          = $::freeradius::params::fr_service
  $fr_modulepath       = $::freeradius::params::fr_modulepath
  $fr_group            = $::freeradius::params::fr_group

  # Validate our inputs
  # Hostnames
  $serverarray = any2array($server)
  unless is_array($serverarray) {
    fail('$server must be an array of hostnames or IP addresses')
  }

  # FR3.0 format server = 'ldap1.example.com, ldap1.example.com, ldap1.example.com'
  # FR3.1 format server = 'ldap1.example.com'
  #              server = 'ldap2.example.com'
  #              server = 'ldap3.example.com'
  $serverconcatarray = $::freeradiusversion ? {
    /^3\.0\./ => join($serverarray, ','),
    default   => $serverarray,
  }

  # Fake booleans (FR uses yes/no instead of true/false)
  unless $starttls in ['yes', 'no'] {
    fail('$starttls must be yes or no')
  }

  # Validate multiple choice options
  unless $requirecert in ['never', 'allow', 'demand', 'hard'] {
    fail('$requirecert must be one of never, allow, demand, hard')
  }

  # Validate integers
  unless is_integer($port) {
    fail('$port must be an integer')
  }
  unless is_integer($uses) {
    fail('$uses must be an integer')
  }
  unless is_integer($idle) {
    fail('$idle must be an integer')
  }
  unless is_integer($probes) {
    fail('$probes must be an integer')
  }
  unless is_integer($interval) {
    fail('$interval must be an integer')
  }
  unless is_integer($timeout) {
    fail('$timeout must be an integer')
  }

  # Generate a module config, based on ldap.conf
  file { "${fr_modulepath}/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/ldap.erb'),
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
