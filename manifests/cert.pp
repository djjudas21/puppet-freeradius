# Install FreeRADIUS certificates
define freeradius::cert (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Optional[String] $type     = 'key',
  Freeradius::Ensure $ensure = present,
) {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  $permission = $type ? {
    'key'   => '0640',
    'cert'  => '0644',
    default => '0644',
  }

  file { "${basepath}/certs/${name}":
    ensure    => $ensure,
    mode      => $permission,
    owner     => 'root',
    group     => $group,
    source    => $source,
    content   => $content,
    show_diff => false,
    require   => [File["${basepath}/certs"], Package[$package_name], Group[$group]],
    notify    => Service[$service_name],
  }
}
