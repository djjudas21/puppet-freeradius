# Install FreeRADIUS certificates
define freeradius::cert (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Optional[String] $type     = 'key',
  Freeradius::Ensure $ensure = present,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  $permission = $type ? {
    'key'   => '0640',
    'cert'  => '0644',
    default => '0644',
  }

  file { "freeradius certs/${name}":
    ensure    => $ensure,
    path      => "${fr_basepath}/certs/${name}",
    mode      => $permission,
    owner     => 'root',
    group     => $fr_group,
    source    => $source,
    content   => $content,
    show_diff => false,
    require   => [File['freeradius certs'], Package['freeradius'], Group['radiusd']],
    notify    => Service['radiusd'],
  }
}
