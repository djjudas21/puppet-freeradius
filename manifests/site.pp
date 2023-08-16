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
  $package_name  = $freeradius::package_name
  $service_name  = $freeradius::service_name
  $basepath = $freeradius::basepath
  $group    = $freeradius::group

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

  file { "${basepath}/sites-available/${name}":
    ensure  => $ensure,
    mode    => '0640',
    owner   => 'root',
    group   => $group,
    source  => $source,
    content => $manage_content,
    require => [Package[$package_name], Group[$group]],
    notify  => Service[$service_name],
  }
  file { "${basepath}/sites-enabled/${name}":
    ensure => $ensure_link,
    target => "${basepath}/sites-available/${name}",
  }
}
