# @summary Install FreeRADIUS virtual servers (sites)
#
# Install a virtual server (a.k.a. site) from a flat file. Sites are installed into `sites-available`
# and automatically symlinked into `sites-enabled`, to ensure compatibility with package managers.
# Any files in this directory that are *not* managed by Puppet will be removed.
#
# @param ensure
#   Whether the site should be present or not.
# @param source
#   Provide source to a file with the configuration of the site.
# @param content
#   Provide content for the configuartion of the site.
# @param authorize
#   Array of options (as String) for the authorize section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param authenticate
#   Array of options (as String) for the authenticate section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param preacct
#   Array of options (as String) for the preacct section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param accounting
#   Array of options (as String) for the accounting section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param session
#   Array of options (as String) for the session section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param post_auth
#   Array of options (as String) for the post-auth section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param pre_proxy
#   Array of options (as String) for the pre-proxy section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param post_proxy
#   Array of options (as String) for the post-proxy section of the site.
#
#   This parameter is ignored if `source` or `content` are used.
# @param listen
#   Array of listen definitions for the site.
#
#   This parameter is ignored if `source` or `content` are used.
define freeradius::site (
  Freeradius::Ensure $ensure  = present,
  Optional[String] $source    = undef,
  Optional[String] $content   = undef,
  Array[String] $authorize    = [],
  Array[String] $authenticate = [],
  Array[String] $preacct      = [],
  Array[String] $accounting   = [],
  Array[String] $session      = [],
  Array[String] $post_auth    = [],
  Array[String] $pre_proxy    = [],
  Array[String] $post_proxy   = [],
  Array[Hash] $listen         = [],
) {
  $fr_basepath = $freeradius::params::fr_basepath
  $fr_group    = $freeradius::params::fr_group

  $manage_content = $source ? {
    undef   => $content ? {
      undef   => template('freeradius/site.erb'),
      default => $content,
    },
    default => undef,
  }

  $ensure_link = $ensure ? {
    'absent' => 'absent',
    default  => 'link'
  }

  file { "freeradius sites-available/${name}":
    ensure  => $ensure,
    path    => "${fr_basepath}/sites-available/${name}",
    mode    => '0640',
    owner   => 'root',
    group   => $fr_group,
    source  => $source,
    content => $manage_content,
    require => [Package['freeradius'], Group['radiusd']],
    notify  => Service['radiusd'],
  }
  file { "freeradius sites-enabled/${name}":
    ensure => $ensure_link,
    path   => "${fr_basepath}/sites-enabled/${name}",
    target => "${fr_basepath}/sites-available/${name}",
  }
}
