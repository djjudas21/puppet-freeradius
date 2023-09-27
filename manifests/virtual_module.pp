# @summary Define a virtual module, made up of others
#
# Define a virtual module which consists of one or more other modules, for failover or load-balancing purposes.
#
# @example Load virtual module myldap
#   freeradius::virtual_module { 'myldap':
#     submodules => ['ldap1', 'ldap2'],
#     type       => 'redundant-load-balance',
#   }
#
# @param submodules
#   Provide an array of submodules which will be loaded into this virtual module.
# @param ensure
# @param type
#   Type of virtual module. See [virtual modules](http://wiki.freeradius.org/config/Fail-over#virtual-modules)
#   and [load-balancing](http://wiki.freeradius.org/config/load-balancing) for more details.
define freeradius::virtual_module (
  Array[String, 1] $submodules,
  Freeradius::Ensure $ensure = present,
  Enum['redundant','load-balance','redundant-load-balance','group'] $type = 'redundant-load-balance',
  ) {
  $fr_basepath = $freeradius::params::fr_basepath
  $fr_group    = $freeradius::params::fr_group

  file { "freeradius instantiate/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/instantiate/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    content => template('freeradius/virtual_module.erb'),
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
}
