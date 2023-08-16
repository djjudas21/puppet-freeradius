# Install FreeRADIUS policies
define freeradius::policy (
  Optional[String] $source,
  Optional[Integer] $order   = 50,
  Freeradius::Ensure $ensure = present,
) {
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

  # Install policy in policy.d
  file { "${basepath}/policy.d/${name}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => $group,
    source  => $source,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50
  if ($ensure == 'present') {
    concat::fragment { "policy-${name}":
      target  => "${basepath}/policy.conf",
      content => "\t\$INCLUDE ${basepath}/policy.d/${name}",
      order   => $order,
      require => File["${basepath}/policy.d/${name}"],
    }
  }
}
