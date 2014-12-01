# Install FreeRADIUS custom dictionaries
define freeradius::dictionary (
  $source,
  $order = 50,
  $ensure = present,
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Install dictionary in dictionary.d
  file { "${fr_basepath}/dictionary.d/dictionary.${name}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    require => [File["${fr_basepath}/dictionary.d"], Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50

  if ($ensure == 'present') {
    concat::fragment { "dictionary.${name}":
      target  => "${fr_basepath}/dictionary",
      content => "\$INCLUDE ${fr_basepath}/dictionary.d/dictionary.${name}\n",
      order   => $order,
      require => File["${fr_basepath}/dictionary.d/dictionary.${name}"],
    }
  }
}
