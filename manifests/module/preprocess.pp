# @summary freeradius::module::preprocess
#
# @param ensure
# @param moddir
# @param huntgroups
# @param hints
# @param with_ascend_hack
# @param ascend_channels_per_line
# @param with_ntdomain_hack
# @param with_specialix_jetstream_hack
# @param with_cisco_vsa_hack
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
