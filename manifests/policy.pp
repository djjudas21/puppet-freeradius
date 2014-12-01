# Install FreeRADIUS policies
define freeradius::policy (
  $source,
  $order = 50,
  $ensure = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Install policy in policy.d
  file { "${fr_basepath}/policy.d/${name}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50
  if ($ensure == 'present') {
    concat::fragment { "policy-${name}":
      target  => "${fr_basepath}/policy.conf",
      content => "\t\$INCLUDE ${fr_basepath}/policy.d/${name}\n",
      order   => $order,
      require => File["${fr_basepath}/policy.d/${name}"],
    }
  }
}
