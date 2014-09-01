class freeradius::nagios {
  # Add the nrpe user to the radiusd group
  User <| title == 'nrpe' |> { groups +> 'radiusd' }

  # Check radiusd daemon
  @@nagios_service { "check_radiusd_${::fqdn}":
    check_command       => 'check_nrpe!check_radiusd',
    service_description => 'RADIUS',
    use                 => '1min-service',
  }
  @@nagios_servicedependency { "check_radiusd_${::fqdn}":
    dependent_host_name           => $::fqdn,
    dependent_service_description => 'RADIUS',
    service_description           => 'NRPE',
  }

  # Check certificate expiry
  @@nagios_service { "check_x509cert_${::fqdn}":
    check_command       => 'check_nrpe!check_x509cert',
    service_description => 'SSL certificates',
    use                 => 'hourly-service',
  }
  @@nagios_servicedependency { "check_x509cert_${::fqdn}":
    dependent_host_name           => $::fqdn,
    dependent_service_description => 'SSL certificates',
    service_description           => 'NRPE',
  }

  # Check winbind connectivity
  @@nagios_service { "check_wbinfo_${::fqdn}":
    check_command       => 'check_nrpe!check_wbinfo',
    service_description => 'Winbind',
    use                 => '1min-service',
  }
  @@nagios_servicedependency { "check_wbinfo_${::fqdn}":
    dependent_host_name           => $::fqdn,
    dependent_service_description => 'Winbind',
    service_description           => 'NRPE',
  }

  # Check NTLM auth backend
  @@nagios_service { "check_ntlm_${::fqdn}":
    check_command       => 'check_nrpe!check_ntlm',
    service_description => 'NTLM',
    use                 => '1min-service',
  }
  @@nagios_servicedependency { "check_ntlm_${::fqdn}":
    dependent_host_name           => $::fqdn,
    dependent_service_description => 'NTLM',
    service_description           => 'NRPE',
  }

  # Check RADIUS status server
  @@nagios_service { "check_radsstest_${::fqdn}":
    check_command       => 'check_radsstest',
    service_description => 'RADIUS status',
    use                 => '3min-service',
  }

  @@nagios_service { "check_radius_statistics_${::fqdn}":
    check_command       => 'check_radius_status',
    service_description => 'RADIUS statistics',
    use                 => '1min-service',
  }

  # Each server being monitored by RADIUS Statistics needs this file creating on monitor
  @@file { "/tmp/radius-stats-${::ipaddress}.ini":
    ensure => present,
    tag    => 'radius-statistics.ini',
    owner  => 'nagios',
    group  => 'nagios',
    mode   => '0664',
  }
}
