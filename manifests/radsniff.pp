# @summary configure and run radsniff
#
# @param envfile path to the environment file, used by the systemd unit
# @param options commandline options passed to radsniff when it runs
# @param
class freeradius::radsniff (
  Optional[String] $envfile = undef,
  String $options = '',
  Optional[String] $pidfile = undef,
) inherits freeradius::params {
  unless $::freeradius::utils_support {
    fail('freeradius::radsniff requires freeradius have utils_support enabled')
  }

  # Calculate the envfile to use - specified, then calculated, then error if none
  if $envfile {
    $final_envfile = $envfile
  } else {
    if $freeradius::radsniff::fr_radsniff_envfile {
      $final_envfile = $freeradius::radsniff::fr_radsniff_envfile
    } else {
      fail('freeradius::radsniff requires envfile to be explicitly set on this OS')
    }
  }

  # Calculate the pidfile to use - specified, then calculated, then error if none
  if $pidfile {
    $final_pidfile = $pidfile
  } else {
    if $freeradius::radsniff::fr_radsniff_pidfile {
      $final_pidfile = $freeradius::radsniff::fr_radsniff_pidfile
    } else {
      fail('freeradius::radsniff requires pidfile to be explicitly set on this OS')
    }
  }

  $escaped_cmd = $options.regsubst('"','\\\\"','G')

  file { $final_envfile:
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
