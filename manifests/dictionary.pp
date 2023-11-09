# Install FreeRADIUS custom dictionaries
define freeradius::dictionary (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Optional[Integer] $order   = 50,
  Freeradius::Ensure $ensure = 'present',
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  if !$source and !$content {
    fail('source or content parameter must be provided')
  }

  # Install dictionary in dictionary.d
  file { "${fr_basepath}/dictionary.d/dictionary.${name}":
    ensure  => $ensure,
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $content,
    require => [File["${fr_basepath}/dictionary.d"], Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50

  if ($ensure == 'present') {
    concat::fragment { "dictionary.${name}":
      target  => "${fr_basepath}/dictionary",
      content => "\$INCLUDE ${fr_basepath}/dictionary.d/dictionary.${name}",
      order   => $order,
      require => File["${fr_basepath}/dictionary.d/dictionary.${name}"],
    }
  }
}
