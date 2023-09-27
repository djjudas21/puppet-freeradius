# @summary Configure LDAP support for FreeRADIUS
#
# @param identity
# @param password
# @param basedn
# @param server
# @param port
# @param uses
# @param idle
# @param probes
# @param interval
# @param timeout
# @param start
# @param min
# @param max
# @param spare
# @param ensure
# @param starttls
# @param cafile
# @param certfile
# @param keyfile
# @param requirecert
define freeradius::ldap (
  String $identity,
  Freeradius::Password $password,
  String $basedn,
  Array[String] $server         = ['localhost'],
  Integer $port                 = 389,
  Integer $uses                 = 0,
  Integer $idle                 = 60,
  Integer $probes               = 3,
  Integer $interval             = 3,
  Integer $timeout              = 10,
  Freeradius::Integer $start    = "\${thread[pool].start_servers}",
  Freeradius::Integer $min      = "\${thread[pool].min_spare_servers}",
  Freeradius::Integer $max      = "\${thread[pool].max_servers}",
  Freeradius::Integer $spare    = "\${thread[pool].max_spare_servers}",
  Freeradius::Ensure $ensure    = 'present',
  Freeradius::Boolean $starttls = 'no',
  Optional[String] $cafile      = undef,
  Optional[String] $certfile    = undef,
  Optional[String] $keyfile     = undef,
  Enum['never','allow','demand','hard'] $requirecert = 'allow',
) {
  warning('The use of freeradius::ldap is deprecated. You must use freeradius::module::ldap instead')

  freeradius::module::ldap { $name:
    ensure      => $ensure,
    identity    => $identity,
    password    => $password,
    basedn      => $basedn,
    server      => $server,
    port        => $port,
    uses        => $uses,
    idle        => $idle,
    probes      => $probes,
    interval    => $interval,
    timeout     => $timeout,
    start       => $start,
    min         => $min,
    max         => $max,
    spare       => $spare,
    starttls    => $starttls,
    cafile      => $cafile,
    certfile    => $certfile,
    keyfile     => $keyfile,
    requirecert => $requirecert,
  }
}
