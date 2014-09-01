# Install FreeRADIUS virtual servers (sites)
define freeradius::site ($source) {
  file { "/etc/raddb/sites-enabled/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }
}
