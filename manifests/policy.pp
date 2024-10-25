# Install FreeRADIUS policies
define freeradius::policy (
  Optional[String] $source = undef,
  Optional[String] $content = undef,
  Optional[Integer] $order   = 50,
  Freeradius::Ensure $ensure = present,
) {
  $fr_basepath = $::freeradius::params::fr_basepath
  $fr_group    = $::freeradius::params::fr_group

  # Install policy in policy.d
  file { "freeradius policy.d/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/policy.d/${name}",
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $content,
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50
  if ($ensure == 'present') {
    concat::fragment { "freeradius policy-${name}":
      target  => 'freeradius policy.conf',
      content => "\t\$INCLUDE ${fr_basepath}/policy.d/${name}",
      order   => $order,
      require => File["freeradius policy.d/${name}"],
    }
  }
}
