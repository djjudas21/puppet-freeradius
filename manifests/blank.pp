# Blank unneeded config files to reduce complexity
define freeradius::blank {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  file { "${basepath}/${name}":
    mode    => '0644',
    owner   => 'root',
    group   => $group,
    require => [File[$basepath], Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
    content => @(BLANK/L),
      # This file is intentionally left blank to reduce complexity. \
      Blanking it but leaving it present is safer than deleting it, \
      since the package manager will replace some files if they are \
      deleted, leading to unexpected behaviour!
      |-BLANK
  }
}
