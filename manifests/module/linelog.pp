# @summary Specific define to configure linelog module
#
# Install and configure linelog module to log text to files.
#
# @param ensure
#   If the module should `present` or `absent`.
# @param filename
#   The file where the logs will go.
# @param escape_filenames
#   If UTF-8 characters should be escaped from filename.
# @param permissions
#   Unix-style permissions for the log file.
# @param group
#   The Unix group which owns the log file.
# @param syslog_facility
#   Syslog facility (if logging via syslog).
# @param syslog_severity
#   Syslog severity (if logging via syslog).
# @param format
#   The default format string.
# @param reference
#   If it is defined, the line string logged is dynamically expanded and the result is used to find another configuration entry here, with
#   the given name. That name is then used as the format string.
# @param messages
#   The messages defined here are taken from the `reference` expansion.
# @param accounting_request
#   Similar to `messages` but for accounting logs.
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
