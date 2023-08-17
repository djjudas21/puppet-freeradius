# @summary freeradius::module::detail
#
# Install a detail module to write detailed log of accounting records.
#
# @param ensure
#   If the module should `present` or `absent`.
# @param filename
#   The file where the detailed logs will go.
# @param escape_filenames
#   If UTF-8 characters should be escaped from filename.
# @param permissions
#   Unix-style permissions for the log file.
# @param group
#   The Unix group which owns the log file.
# @param header
#   Header to use in every entry in the detail file.
# @param locking
#   Enable if a detail file reader will be reading this file.
# @param log_packet_header
#   Log the package src/dst IP/port.
# @param suppress
#   Array of (sensitive) attributes that should be removed from the log.
define freeradius::module::detail (
  Enum['present','absent'] $ensure                 = 'present',
  String $filename                                 = "\${radacctdir}/%{%{Packet-Src-IP-Address}:-%{Packet-Src-IPv6-Address}}/detail-%Y%m%d",
  Freeradius::Boolean $escape_filenames            = 'no',
  String $permissions                              = '0600',
  Optional[String] $group                          = undef,
  String $header                                   = '%t',
  Optional[Freeradius::Boolean] $locking           = undef,
  Optional[Freeradius::Boolean] $log_packet_header = undef,
  Optional[Array[String]] $suppress                = [],
) {
  freeradius::module { "detail.${name}":
    ensure  => $ensure,
    content => template('freeradius/detail.erb'),
  }
}
