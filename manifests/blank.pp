# Blank unneeded config files to reduce complexity
define freeradius::blank {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "${fr_basepath}/${name}":
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    require => [File[$fr_basepath], Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
    content => @(BLANK/L),
      # This file is intentionally left blank to reduce complexity. \
      Blanking it but leaving it present is safer than deleting it, \
      since the package manager will replace some files if they are \
      deleted, leading to unexpected behaviour!
      |-BLANK
  }
}
