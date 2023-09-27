# @summary Install FreeRADIUS config snippets
#
# @example
#   freeradius::attr { 'eduroamlocal':
#     key    => 'User-Name',
#     prefix => 'attr_filter',
#     source => 'puppet:///modules/site_freeradius/eduroamlocal',
#   }
#
# @param source
# @param ensure
# @param key
#   Specify a RADIUS attribute to be the key for this attribute filter. Enter only the string part of the name.
# @param prefix
#   Specify the prefix for the attribute filter name before the dot, e.g. `filter.post_proxy`. This is usually set to `filter` on FR2 and
#   `attr_filter` on FR3.
# @param relaxed
#   Whether the filter removes or copies unmatched attributes, relaxed = no or yes respectively. An undefined value results in no
#   explicit statement, causing the default behaviour of FreeRADIUS equivalent to 'relaxed = no'.
define freeradius::attr (
  String $source,
  Freeradius::Ensure $ensure             = present,
  Optional[String] $key                  = 'User-Name',
  Optional[String] $prefix               = 'filter',
  Optional[Freeradius::Boolean] $relaxed = undef,
) {
  $fr_group            = $freeradius::params::fr_group
  $fr_moduleconfigpath = $freeradius::params::fr_moduleconfigpath

  # Install the attribute filter snippet
  file { "freeradius attr_filter/${name}":
    ensure  => $ensure,
    path    => "${fr_moduleconfigpath}/attr_filter/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }

  # Reference all attribute snippets in one file
  concat::fragment { "freeradius attr-${name}":
    target  => 'freeradius mods-available/attr_filter',
    content => template('freeradius/attr.erb'),
    order   => 20,
  }
}
