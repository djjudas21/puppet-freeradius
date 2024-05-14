# == Define freeradius::listen
#
define freeradius::listen (
  Freeradius::Ensure $ensure                                 = 'present',
  Enum['auth','acct','proxy','detail','status','coa'] $type  = 'auth',
  Optional[Variant[Stdlib::IP::Address::V4, Enum['*']]] $ip  = undef,
  Optional[Variant[Stdlib::IP::Address::V6, Enum['*']]] $ip6 = undef,
  Integer $port                                              = 0,
  Optional[String] $interface                                = undef,
  Optional[String] $virtual_server                           = undef,
  Array[String] $clients                                     = [],
  Integer $max_connections                                   = 16,
  Integer $lifetime                                          = 0,
  Integer $idle_timeout                                      = 30,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

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
