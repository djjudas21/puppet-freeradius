# @summary Install FreeRADIUS modules
#
# Install a module from a flat file, or enable a stock module that came with your distribution of
# FreeRADIUS. Modules are installed into `mods-available` and automatically symlinked into
# `mods-enabled`, to ensure compatibility with package managers. Any files in this directory that
# are *not* managed by Puppet will be removed.
#
# @example Enable a stock module
#   freeradius::module { 'pap':
#     preserve => true,
#   }
#
# @example Install a custom module from a flat file
#   freeradius::module { 'buffered-sql':
#     source => 'puppet:///modules/site_freeradius/buffered-sql',
#   }
#
# @example Install a custom module from a template
#   freeradius::module { 'buffered-sql':
#     content => template('some_template.erb)',
#   }
#
# @param source
# @param content
# @param ensure
# @param preserve
define freeradius::module (
  Optional[String] $source   = undef,
  Optional[String] $content  = undef,
  Freeradius::Ensure $ensure = present,
  Boolean $preserve          = false,
) {
  $fr_modulepath = $freeradius::params::fr_modulepath
  $fr_basepath   = $freeradius::params::fr_basepath
  $fr_group      = $freeradius::params::fr_group

  $ensure_link = $ensure ? {
    'absent' => 'absent',
    default  => 'link'
  }

  if ($preserve) {
    # Symlink to mods-available for stock modules
    file { "freeradius mods-enabled/${name}":
      ensure => $ensure_link,
      path   => "${fr_modulepath}/${name}",
      target => "../mods-available/${name}",
      notify => Service['radiusd'],
    }
  } else {
    # Deploy actual module to mods-available, and link it to mods-enabled
    file { "freeradius mods-available/${name}":
      ensure  => $ensure,
      path    => "${fr_basepath}/mods-available/${name}",
      mode    => '0640',
      owner   => 'root',
      group   => $fr_group,
      source  => $source,
      content => $content,
      require => [Package['freeradius'], Group['radiusd']],
      notify  => Service['radiusd'],
    }
    file { "freeradius mods-enabled/${name}":
      ensure  => $ensure_link,
      path    => "${fr_modulepath}/${name}",
      target  => "../mods-available/${name}",
      require => File["freeradius mods-available/${name}"],
      notify  => Service['radiusd'],
    }
  }
}
