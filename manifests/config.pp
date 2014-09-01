# Install FreeRADIUS config snippets
define freeradius::config ($source) {
  file { "/etc/raddb/conf.d/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => File['/etc/raddb/conf.d'],
    notify  => Service['radiusd'],
  }
}
