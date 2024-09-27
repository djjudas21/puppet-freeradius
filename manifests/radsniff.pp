# @summary configure and run radsniff
#
# @param envfile path to the environment file, used by the systemd unit
# @param options commandline options passed to radsniff when it runs
# @param
class freeradius::radsniff (
  String $envfile = $freeradius::params::fr_radsniff_envfile,
  Optional[String] $options = undef,
  String $pidfile = $freeradius::params::fr_radsniff_pidfile,
) inherits freeradius::params {
  unless $::freeradius::utils_support {
    fail('freeradius::radsniff requires freeradius have utils_support enabled')
  }

  $escaped_cmd = $options ? {
    String[1] => $options.regsubst('"','\\\\"','G'),
    default   => '',
  }

  file { 'freeradius radsniff envfile':
    ensure  => file,
    path    => $envfile,
    content => @("SYSCONFIG"),
      RADSNIFF_OPTIONS="${escaped_cmd}"
      | SYSCONFIG
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['freeradius-utils'],
  }
  ~> service { 'radsniff':
    ensure => running,
    enable => true,
  }

  systemd::unit_file { 'radsniff.service':
    content => template('freeradius/radsniff.service.erb'),
    notify  => Service['radsniff'],
  }
}
