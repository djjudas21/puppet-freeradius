# @summary Install FreeRADIUS custom dictionaries
#
# Install custom dictionaries without breaking the default FreeRADIUS dictionary.
# Custom dictionaries are installed in `dictionary.d` and automatically included in the global dictionary.
#
# @example
#   freeradius::dictionary { 'mydict':
#     source => 'puppet:///modules/site_freeradius/dictionary.mydict',
#   }
#
# @param source
# @param content
# @param order
# @param ensure
define freeradius::dictionary (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Optional[Integer] $order   = 50,
  Freeradius::Ensure $ensure = 'present',
) {
  $fr_basepath = $freeradius::params::fr_basepath
  $fr_group    = $freeradius::params::fr_group

  if !$source and !$content {
    fail('source or content parameter must be provided')
  }

  # Install dictionary in dictionary.d
  file { "freeradius dictionary.d/dictionary.${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/dictionary.d/dictionary.${name}",
    mode    => '0644',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $content,
    require => [File['freeradius dictionary.d'], Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }

  # Reference policy.d in the global includes file
  # If no order priority is given, assume 50

  if ($ensure == 'present') {
    concat::fragment { "dictionary.${name}":
      target  => 'freeradius dictionary',
      content => "\$INCLUDE ${fr_basepath}/dictionary.d/dictionary.${name}",
      order   => $order,
      require => File["freeradius dictionary.d/dictionary.${name}"],
    }
  }
}
