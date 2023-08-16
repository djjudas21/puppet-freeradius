# Install FreeRADIUS modules
define freeradius::module (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Freeradius::Ensure $ensure = present,
  Boolean $preserve          = false,
) {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $modulepath = $freeradius::modulepath
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  $ensure_link = $ensure ? {
    'absent' => 'absent',
    default  => 'link'
  }

  if ($preserve) {
    # Symlink to mods-available for stock modules
    file { "${modulepath}/${name}":
      ensure => $ensure_link,
      target => "../mods-available/${name}",
      notify => Service[$service_name],
    }
  } else {
    # Deploy actual module to mods-available, and link it to mods-enabled
    file { "${basepath}/mods-available/${name}":
      ensure  => $ensure,
      mode    => '0640',
      owner   => 'root',
      group   => $group,
      source  => $source,
      content => $content,
      require => [Package[$package_name], Group[$group]],
      notify  => Service[$service_name],
    }
    file { "${modulepath}/${name}":
      ensure  => $ensure_link,
      target  => "../mods-available/${name}",
      require => File["${basepath}/mods-available/${name}"],
      notify  => Service[$service_name],
    }
  }
}
