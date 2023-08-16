# Install FreeRADIUS config snippets
define freeradius::config (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Freeradius::Ensure $ensure = present,
) {
  $package_name          = $freeradius::package_name
  $service_name          = $freeradius::service_name
  $group            = $freeradius::group
  $moduleconfigpath = $freeradius::moduleconfigpath

  file { "${moduleconfigpath}/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    source  => $source,
    content => $content,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }
}
