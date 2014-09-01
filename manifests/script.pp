# Install FreeRADIUS helper scripts
define freeradius::script ($source) {
  file { "/etc/raddb/scripts/${name}":
    mode    => '0750',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => File['/etc/raddb/scripts'],
  }
}
