# Install FreeRADIUS config snippets
define freeradius::attr (
  String $source,
  Freeradius::Ensure $ensure             = present,
  Optional[String] $key                  = 'User-Name',
  Optional[String] $prefix               = 'filter',
  Optional[Freeradius::Boolean] $relaxed = undef,
) {
  $package_name          = $freeradius::package_name
  $service_name          = $freeradius::service_name
  $basepath         = $freeradius::basepath
  $group            = $freeradius::group
  $moduleconfigpath = $freeradius::moduleconfigpath
  $modulepath       = $freeradius::modulepath

  # Install the attribute filter snippet
  file { "${moduleconfigpath}/attr_filter/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    source  => $source,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Reference all attribute snippets in one file
  concat::fragment { "attr-${name}":
    target  => "${basepath}/mods-available/attr_filter",
    content => template('freeradius/attr.erb'),
    order   => 20,
  }
}
