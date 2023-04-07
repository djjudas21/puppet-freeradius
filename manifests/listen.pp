# == Define freeradius::listen
#
define freeradius::listen (
  Freeradius::Ensure $ensure                                = 'present',
  Enum['auth','acct','proxy','detail','status','coa'] $type = 'auth',
  Optional[String] $ip                                      = undef,
  Optional[String] $ip6                                     = undef,
  Integer $port                                             = 0,
  Optional[String] $interface                               = undef,
  Optional[String] $virtual_server                          = undef,
  Array[String] $clients                                    = [],
  Integer $max_connections                                  = 16,
  Integer $lifetime                                         = 0,
  Integer $idle_timeout                                     = 30,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Parameter validation
  if $ip and $ip != '*' and !is_ip_address($ip) {
    fail('ip must be a valid IP address or \'*\'')
  }

  if $ip6 and $ip6 != '::' and !is_ip_address($ip6) {
    fail('ip6 must be a valid IP address or \'::\'')
  }

  if $ip and $ip6 {
    fail('Only one of ip or ip6 can be used')
  }

  file { "freeradius listen.d/${name}.conf":
    ensure  => $ensure,
    path    => "${fr_basepath}/listen.d/${name}.conf",
    owner   => 'root',
    group   => $fr_group,
    mode    => '0640',
    content => template('freeradius/listen.erb'),
    require => [
      File['freeradius listen.d'],
      Group['radiusd'],
    ],
    notify  => Service['radiusd'],
  }
}
