# @summary Create the perl module configuration for FreeRADIUS
#
# Installs the Perl module [rlm_perl](https://wiki.freeradius.org/modules/rlm_perl) with more advanced configuration
#
# @example
#   freeradius::module::perl { 'somename':
#     perl_filename  => 'scriptname.pl',
#     path           => "puppet:///modules/profiles/radius_proxy/",
#     function_names => $function_names,
#   }
#
# @param ensure
# @param moddir
# @param perl_filename
#   Filename of the Perl script.
# @param path
#   The path of the source file on the Puppet server.
# @param content
# @param function_names
#   If different function names to default are used, or if seperate functions for accounting start and stop are used, just pass a hash of
#   default and actual function names.
#   ```puppet
#   $function_names = {
#     "func_authenticate"     => "alternative_name",
#     "func_start_accounting" => "start_function",
#     "func_stop_accounting"  => "stop_function",
#   }
#   ```
define freeradius::module::perl (
  Optional[String] $ensure                       = file,
  String $moddir                                 = "${fr_moduleconfigpath}/perl",
  Optional[String] $perl_filename                = undef,
  Optional[String] $path                         = undef,
  Optional[String] $content                      = undef,
  Optional[Hash[String, String]] $function_names = undef,
) {
  $fr_moduleconfigpath = $freeradius::params::fr_moduleconfigpath
  $fr_group            = $freeradius::params::fr_group
  $fr_service          = $freeradius::params::fr_service
  $source              = "${path}/${perl_filename}"

  freeradius::module { 'perl':
    ensure  => $ensure,
    content => template('freeradius/perl.erb'),
  }

  file { "${fr_moduleconfigpath}/perl/${perl_filename}":
    ensure  => file,
    owner   => 'root',
    group   => $fr_group,
    mode    => '0640',
    source  => $source,
    content => $content,
    require => Freeradius::Module['perl'],
    notify  => Service[$fr_service],
  }
}
