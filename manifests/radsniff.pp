# @summary configure and run radsniff
#
# @param options commandline options passed to radsniff when it runs
class freeradius::radsniff (
  String $options = '',
) {
  unless $::freeradius::utils_support {
    fail('freeradius::radsniff requires freeradius have utils_support enabled')
  }

  unless $facts['os']['family'] == 'RedHat' {
    fail('freeradius::radsniff only supports RedHat like OSes at the moment')
  }

  $escaped_cmd = $options.regsubst('"','\\\\"','G')

  file {'/etc/sysconfig/radsniff':
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

  systemd::unit_file {'radsniff.service':
    source => 'puppet:///modules/freeradius/radsniff.service',
    notify => Service['radsniff'],
  }
}
