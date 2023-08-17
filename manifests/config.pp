# @summary Install FreeRADIUS config snippets
#
# Install arbitrary config snippets from a flat file. These are installed in `mods-config`
#
# @example
#   freeradius::config { 'realm-checks.conf':
#     source => 'puppet:///modules/site_freeradius/realm-checks.conf',
#   }
#
# @example
#   freeradius::config { 'realm-checks.conf':
#     content => template('your_template),
#   }
#
# @param source
# @param content
# @param ensure
define freeradius::config (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Freeradius::Ensure $ensure = present,
) {
  $fr_group            = $freeradius::params::fr_group
  $fr_moduleconfigpath = $freeradius::params::fr_moduleconfigpath

  file { "freeradius mods-config/${name}":
    ensure  => $ensure,
    path    => "${fr_moduleconfigpath}/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $content,
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
}
