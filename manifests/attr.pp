# Install FreeRADIUS config snippets
define freeradius::attr (
  String $source,
  Freeradius::Ensure $ensure             = present,
  Optional[String] $key                  = 'User-Name',
  Optional[String] $prefix               = 'filter',
  Optional[Freeradius::Boolean] $relaxed = undef,
) {
  $fr_group            = $::freeradius::params::fr_group
  $fr_moduleconfigpath = $::freeradius::params::fr_moduleconfigpath

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
