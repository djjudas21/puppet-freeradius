# Install FreeRADIUS modules
define freeradius::module (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Freeradius::Ensure $ensure = present,
  Boolean $preserve          = false,
) {
  $fr_modulepath = $::freeradius::params::fr_modulepath
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  $ensure_link = $ensure ? {
    'absent' => 'absent',
    default  => 'link'
  }

  if ($preserve) {
    # Symlink to mods-available for stock modules
    file { "freeradius mods-enabled/${name}":
      ensure => $ensure_link,
      path   => "${fr_modulepath}/${name}",
      target => "../mods-available/${name}",
      notify => Service['radiusd'],
    }
  } else {
    # Deploy actual module to mods-available, and link it to mods-enabled
    file { "freeradius mods-available/${name}":
      ensure  => $ensure,
      path    => "${fr_basepath}/mods-available/${name}",
      mode    => '0640',
      owner   => 'root',
      group   => $fr_group,
      source  => $source,
      content => $content,
      require => [Package['freeradius'], Group['radiusd']],
      notify  => Service['radiusd'],
    }
    file { "freeradius mods-enabled/${name}":
      ensure  => $ensure_link,
      path    => "${fr_modulepath}/${name}",
      target  => "../mods-available/${name}",
      require => File["freeradius mods-available/${name}"],
      notify  => Service['radiusd'],
    }
  }
}
