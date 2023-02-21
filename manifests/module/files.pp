# == Define freeradius::module::files
#
# Create e file module configuration for FreeRADIUS
#
define freeradius::module::files (
  $ensure                              = 'present',
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
  $fr_moduleconfigpath = $::freeradius::params::fr_moduleconfigpath
  $fr_group            = $::freeradius::params::fr_group
  $fr_service          = $::freeradius::params::fr_service

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
