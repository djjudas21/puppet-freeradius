# Install FreeRADIUS virtual servers (sites)
define freeradius::site (
  Freeradius::Ensure $ensure  = present,
  Optional[String] $source    = undef,
  Optional[String] $content   = undef,
  Array[String] $authorize    = [],
  Array[String] $authenticate = [],
  Array[String] $preacct      = [],
  Array[String] $accounting   = [],
  Array[String] $session      = [],
  Array[String] $post_auth    = [],
  Array[String] $pre_proxy    = [],
  Array[String] $post_proxy   = [],
  Array[Hash] $listen         = [],
) {
  $fr_package  = $::freeradius::params::fr_package
  $fr_service  = $::freeradius::params::fr_service
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  $manage_content = $source ? {
    undef   => $content ? {
      undef   => template('freeradius/site.erb'),
      default => $content,
    },
    default => undef,
  }

  $ensure_link = $ensure ? {
    'absent' => 'absent',
    default  => 'link'
  }

  file { "${fr_basepath}/sites-available/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $manage_content,
    require => [Package[$fr_package], Group[$fr_group]],
    notify  => Service[$fr_service],
  }
  file { "${fr_basepath}/sites-enabled/${name}":
    ensure => $ensure_link,
    target => "${fr_basepath}/sites-available/${name}",
  }
}
