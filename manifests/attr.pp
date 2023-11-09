# Install FreeRADIUS config snippets
define freeradius::attr (
  String $source,
  Freeradius::Ensure $ensure             = present,
  Optional[String] $key                  = 'User-Name',
  Optional[String] $prefix               = 'filter',
  Optional[Freeradius::Boolean] $relaxed = undef,
) {
  $fr_package          = $::freeradius::params::fr_package
  $fr_service          = $::freeradius::params::fr_service
  $fr_basepath         = $::freeradius::params::fr_basepath
  $fr_group            = $::freeradius::params::fr_group
  $fr_moduleconfigpath = $::freeradius::params::fr_moduleconfigpath
  $fr_modulepath       = $::freeradius::params::fr_modulepath

  # Install the attribute filter snippet
  file { "${fr_moduleconfigpath}/attr_filter/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  # Reference all attribute snippets in one file
  concat::fragment { "attr-${name}":
    target  => "${fr_basepath}/mods-available/attr_filter",
    content => template('freeradius/attr.erb'),
    order   => 20,
  }
}
