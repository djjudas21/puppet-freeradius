# @summary freeradius::module::preprocess
#
# Install a preprocess module to process _huntgroups_ and _hints_ files.
#
# @param ensure
#   If the module should `present` or `absent`.
# @param moddir
#   Directory where the preprocess' files are located.
# @param huntgroups
#   Path for the huntgroups file.
# @param hints
#   Path for the hints file.
# @param with_ascend_hack
#   This hack changes Ascend's weird port numbering to standar 0-??? port numbers.
# @param ascend_channels_per_line
# @param with_ntdomain_hack
#   Windows NT machines often authenticate themselves as `NT_DOMAIN\username`.
#   If this parameter is set to `yes`, then the `NT_DOMAIN` portion of the user-name is silently discarded.
# @param with_specialix_jetstream_hack
#   Set to `yes` if you are using a Specialix Jetstream 8500 access server.
# @param with_cisco_vsa_hack
#   Set to `yes` if you are using a Cisco or Quintum NAS.
class freeradius::module::preprocess (
  Enum['present','absent'] $ensure                   = 'present',
  String $moddir                                     = "\${modconfdir}/\${.:instance}",
  String $huntgroups                                 = "\${moddir}/huntgroups",
  String $hints                                      = "\${moddir}/hints",
  Freeradius::Boolean $with_ascend_hack              = 'no',
  Integer $ascend_channels_per_line                  = 23,
  Freeradius::Boolean $with_ntdomain_hack            = 'no',
  Freeradius::Boolean $with_specialix_jetstream_hack = 'no',
  Freeradius::Boolean $with_cisco_vsa_hack           = 'no',
) {
  $fr_moduleconfigpath = $freeradius::params::fr_moduleconfigpath
  $fr_group            = $freeradius::params::fr_group
  $fr_service          = $freeradius::params::fr_service

  freeradius::module { 'preprocess':
    ensure  => $ensure,
    content => template('freeradius/preprocess.erb'),
  }
}
