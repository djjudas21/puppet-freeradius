# @summary Configure a template snippet
#
# @param source
# @param content
define freeradius::template (
  Optional[String] $source  = undef,
  Optional[String] $content = undef,
) {
  # Configure config fragment for this template
  concat::fragment { "freeradius template ${name}":
    target  => 'freeradius templates.conf',
    source  => $source,
    content => $content,
    order   => 10,
  }
}
