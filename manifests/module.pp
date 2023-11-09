# Install FreeRADIUS modules
define freeradius::module (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Freeradius::Ensure $ensure = present,
  Boolean $preserve          = false,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_modulepath = $::freeradius::params::fr_modulepath
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  $ensure_link = $ensure ? {
    'absent' => 'absent',
    default  => 'link'
  }

  if ($preserve) {
    # Symlink to mods-available for stock modules
    file { "${fr_modulepath}/${name}":
      ensure => $ensure_link,
      target => "../mods-available/${name}",
      notify => Service[$fr_service],
    }
  } else {
    # Deploy actual module to mods-available, and link it to mods-enabled
    file { "${fr_basepath}/mods-available/${name}":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'root',
      group   => $fr_group,
      source  => $source,
      content => $content,
      require => [Package[$fr_package], Group[$fr_group]],
      notify  => Service[$fr_service],
    }
    file { "${fr_modulepath}/${name}":
      ensure  => $ensure_link,
      target  => "../mods-available/${name}",
      require => File["${fr_basepath}/mods-available/${name}"],
      notify  => Service[$fr_service],
    }
  }
}
