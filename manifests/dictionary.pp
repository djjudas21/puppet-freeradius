# Install FreeRADIUS custom dictionaries
define freeradius::dictionary (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Optional[Integer] $order   = 50,
  Freeradius::Ensure $ensure = 'present',
) {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  if !$source and !$content {
    fail('source or content parameter must be provided')
  }

  # Install dictionary in dictionary.d
  file { "${basepath}/dictionary.d/dictionary.${name}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => $group,
    source  => $source,
    content => $content,
    require => [File["${basepath}/dictionary.d"], Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50

  if ($ensure == 'present') {
    concat::fragment { "dictionary.${name}":
      target  => "${basepath}/dictionary",
      content => "\$INCLUDE ${basepath}/dictionary.d/dictionary.${name}",
      order   => $order,
      require => File["${basepath}/dictionary.d/dictionary.${name}"],
    }
  }
}
