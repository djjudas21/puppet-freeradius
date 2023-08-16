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
  $moduleconfigpath = $freeradius::moduleconfigpath
  $group            = $freeradius::group
  $service_name          = $freeradius::service_name

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
    $userspath = "${moduleconfigpath}/${name}/${1}"
    $usersdir  = "${moduleconfigpath}/${name}"
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
    group   => $group,
    mode    => '0750',
    require => Freeradius::Module[$name],
  }

  file { $userspath:
    ensure  => $ensure,
    owner   => 'root',
    group   => $group,
    mode    => '0640',
    source  => $source,
    content => $manage_content,
    require => File[$usersdir],
    notify  => Service[$service_name],
  }
}
