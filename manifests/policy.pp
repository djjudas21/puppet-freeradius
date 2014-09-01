# Install FreeRADIUS policies
define freeradius::policy ($source, $order=50) {
  # Install policy in policy.d 
  file { "/etc/raddb/policy.d/${name}":
    mode    => '0644',
    owner   => 'root',
    group   => 'radiusd',
    source  => $source,
    require => Package['freeradius'],
    notify  => Service['radiusd'],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50
  concat::fragment { "policy-${name}":
    target  => '/etc/raddb/policy.conf',
    content => "\t\$INCLUDE /etc/raddb/policy.d/${name}\n",
    order   => $order,
    require => File["/etc/raddb/policy.d/${name}"],
  }

}
