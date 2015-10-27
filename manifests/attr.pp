# Install FreeRADIUS config snippets
define freeradius::attr (
  $source,
  $ensure = present,
  $key = 'User-Name',
) {
  $fr_package          = $::freeradius::params::fr_package
  $fr_service          = $::freeradius::params::fr_service
  $fr_basepath         = $::freeradius::params::fr_basepath
  $fr_group            = $::freeradius::params::fr_group
  $fr_moduleconfigpath = $::freeradius::params::fr_moduleconfigpath
  $fr_modulepath       = $::freeradius::params::fr_modulepath

  # Decide on location for attribute filters
  $location = $::freeradius_maj_version ? {
    2       => $fr_basepath,
    3       => "$fr_moduleconfigpath/attr_filter",
    default => $fr_moduleconfigpath,
  }

  # Install the attribute filter snippet
  file { "${location}/${name}":
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
    target  => "${fr_modulepath}/attr_filter",
    content => template("freeradius/attr.fr${::freeradius_maj_version}.erb"),
  }
}
