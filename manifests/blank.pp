# Blank unneeded config files to reduce complexity
define freeradius::blank {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  file { "freeradius ${name}":
    path    => "${fr_basepath}/${name}",
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    require => [File['freeradius raddb'], Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
    content => @(BLANK/L),
               # This file is intentionally left blank to reduce complexity. \
               Blanking it but leaving it present is safer than deleting it, \
               since the package manager will replace some files if they are \
               deleted, leading to unexpected behaviour!
               |-BLANK
  }
}
