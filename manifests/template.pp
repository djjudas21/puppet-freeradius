# Configure a template snippet
define freeradius::template (
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
) {
  $basepath = $freeradius::basepath

  # Configure config fragment for this template
  concat::fragment { "template -${name}":
    target  => "${basepath}/templates.conf",
    source  => $source,
    content => $content,
    order   => 10,
  }
}
