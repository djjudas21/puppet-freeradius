# == Define freeradius::module::perl
#
# Create the perl module configuration for FreeRADIUS
#
define freeradius::module::perl (
  Optional[String] $ensure                       = file,
  String $moddir                                 = "${moduleconfigpath}/perl",
  Optional[String] $perl_filename                = undef,
  Optional[String] $path                         = undef,
  Optional[String] $content                      = undef,
  Optional[Hash[String, String]] $function_names = undef,
) {
  $moduleconfigpath = $freeradius::moduleconfigpath
  $group            = $freeradius::group
  $service_name          = $freeradius::service_name
  $source              = "${path}/${perl_filename}"
  freeradius::module { 'perl':
    ensure  => $ensure,
    content => template('freeradius/perl.erb'),
  }

  file { "${moduleconfigpath}/perl/${perl_filename}":
    ensure  => file,
    owner   => 'root',
    group   => $group,
    mode    => '0640',
    source  => $source,
    content => $content,
    require => Freeradius::Module['perl'],
    notify  => Service[$service_name],
  }
}
