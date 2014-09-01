# Instantiate a module in global config
define freeradius::instantiate {
  file { "/etc/raddb/instantiate/${name}":
    mode    => '0640',
    owner   => 'root',
    group   => 'radiusd',
    content => $name,
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }
}
