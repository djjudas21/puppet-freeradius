# Configure a template snippet
define freeradius::template (
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
) {
  $fr_basepath = $::freeradius::params::fr_basepath

  # Configure config fragment for this template
  concat::fragment { "template -${name}":
    target  => "${fr_basepath}/templates.conf",
    source  => $source,
    content => $content,
    order   => 10,
  }
}
