# Install FreeRADIUS virtual servers (sites)
define freeradius::site (
  $source  = undef,
  $content = undef,
) {
  file { "/etc/raddb/sites-enabled/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    content => $content,
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }
}
