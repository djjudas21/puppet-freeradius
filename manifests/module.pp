# Install FreeRADIUS modules
define freeradius::module ($source) {
  file { "/etc/raddb/modules/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }
}
