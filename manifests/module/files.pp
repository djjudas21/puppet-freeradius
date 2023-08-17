# @summary Create e file module configuration for FreeRADIUS
#
# Install a `file` module with users in freeradius.
#
# @example
#   freeradius::module::files {'myuserfile':
#     users => [
#       {
#         login => 'DEFAULT',
#         check_items => [
#           'Realm == NULL'
#         ],
#         reply_items => [
#           'Fall-Through = No
#         ],
#       },
#     ],
#   }
#
#   # will produce a user file like:
#   DEFAULT Realm == NULL
#     Fall-Through = No
#
# @param ensure
#   If the module should `present` or `absent`.
# @param moddir
#   Directory where the users file is located.
# @param key
#   The default key attribute to use for matches.
# @param filename
#   The (old) users style filename.
# @param usersfile
#   Accepted for backups compatibility.
# @param acctusersfile
#   Accepted for backups compatibility.
# @param preproxy_usersfile
#   Accepted for backups compatibility.
# @param users
#   Array of hashes with users entries (see "man users"). If entry in the hash is an array which valid keys are:
#   * `login`: The login of the user.
#   * `check_items`: An array with check components for the user entry.
#   * `reply_items`: An array with reply components for the user entry.
#
#   You should use just one of `users`, `source` or `content` parameters.
# @param source
#   Provide source to a file with the users file.
#
#   You should use just one of `users`, `source` or `content` parameters.
# @param content
#   Provide the content for the users file.
#
#   You should use just one of `users`, `source` or `content` parameters.
define freeradius::module::files (
  String $ensure                       = 'present',
  String $moddir                       = "\${modconfdir}/\${.:instance}",
  Optional[String] $key                = undef,
  String $filename                     = "\${moddir}/authorize",
  Optional[String] $usersfile          = undef,
  Optional[String] $acctusersfile      = undef,
  Optional[String] $preproxy_usersfile = undef,
  Array $users                         = [],
  Optional[String] $source             = undef,
  Optional[String] $content            = undef,
) {
  $fr_moduleconfigpath = $freeradius::params::fr_moduleconfigpath
  $fr_group            = $freeradius::params::fr_group
  $fr_service          = $freeradius::params::fr_service

  $manage_content = $content ? {
    undef     => $source ? {
      undef   => template('freeradius/users.erb'),
      default => undef,
    },
    default   => $content,
  }

  $manage_dir = $ensure ? {
    'present' => 'directory',
    default   => 'absent',
  }

  if $filename =~ /^\$\{moddir\}\/(.+)$/ {
    $userspath = "${fr_moduleconfigpath}/${name}/${1}"
    $usersdir  = "${fr_moduleconfigpath}/${name}"
  } else {
    $userspath = $filename
    $usersdir  = dirname($filename)
  }

  freeradius::module { $name:
    ensure  => $ensure,
    content => template('freeradius/files.erb'),
  }

  file { $usersdir:
    ensure  => $manage_dir,
    owner   => 'root',
    group   => $fr_group,
    mode    => '0750',
    require => Freeradius::Module[$name],
  }

  file { $userspath:
    ensure  => $ensure,
    owner   => 'root',
    group   => $fr_group,
    mode    => '0640',
    source  => $source,
    content => $manage_content,
    require => File[$usersdir],
    notify  => Service[$fr_service],
  }
}
