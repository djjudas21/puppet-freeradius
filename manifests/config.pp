# Install FreeRADIUS config snippets
define freeradius::config (
  $source = undef,
  $content = undef,
  $ensure = present,
) {
  $fr_package          = $::freeradius::params::fr_package
  $fr_service          = $::freeradius::params::fr_service
  $fr_group            = $::freeradius::params::fr_group
  $fr_moduleconfigpath = $::freeradius::params::fr_moduleconfigpath

  file { "${fr_moduleconfigpath}/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $content,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
}
