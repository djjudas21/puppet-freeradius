# Install FreeRADIUS config snippets
define freeradius::attr ($source) {
  file { "/etc/raddb/attr.d/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => File['/etc/raddb/attr.d'],
    notify  => Service['radiusd'],
  }
}
