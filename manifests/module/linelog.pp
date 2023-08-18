# @summary Specific define to configure linelog module
#
# @param ensure
# @param filename
# @param escape_filenames
# @param permissions
# @param group
# @param syslog_facility
# @param syslog_severity
# @param format
# @param reference
# @param messages
# @param accounting_request
define freeradius::module::linelog (
  Enum['present','absent'] $ensure      = 'present',
  String $filename                      = "\${logdir}/linelog",
  Freeradius::Boolean $escape_filenames = 'no',
  String $permissions                   = '0600',
  Optional[String] $group               = undef,
  Optional[String] $syslog_facility     = undef,
  Optional[String] $syslog_severity     = undef,
  String $format                        = 'This is a log message for %{User-Name}',
  String $reference                     = 'messages.%{%{reply:Packet-Type}:-default}',
  Array[String] $messages               = [],
  Array[String] $accounting_request     = [],
) {
  freeradius::module { "linelog_${name}":
    ensure  => $ensure,
    content => template('freeradius/linelog.erb'),
  }
}
