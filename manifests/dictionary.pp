# Install FreeRADIUS custom dictionaries
define freeradius::dictionary ($source, $order=50) {
  $fr_package = $::freeradius::params::fr_package
  $fr_service = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath

  # Install dictionary in dictionary.d 
  file { "${fr_basepath}/dictionary.d/dictionary.${name}":
    mode    => '0644',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => Package[$fr_package],
    notify  => Service[$fr_service],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50
  concat::fragment { "dictionary.${name}":
    target  => "${fr_basepath}/dictionary",
    content => "\$INCLUDE ${fr_basepath}/dictionary.d/dictionary.${name}\n",
    order   => $order,
    require => File["${fr_basepath}/dictionary.d/dictionary.${name}"],
  }
}
