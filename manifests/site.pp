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

  file { "freeradius sites-available/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/sites-available/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $manage_content,
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
  file { "freeradius sites-enabled/${name}":
    ensure => $ensure_link,
    path   => "${fr_basepath}/sites-enabled/${name}",
    target => "../sites-available/${name}",
  }
}
