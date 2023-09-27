# @summary Configure a template snippet
#
# Define template items that can be referred to in other config items
#
# @param source
#   Provide source to a file with the template item. Specify only one of `source` or `content`.
# @param content
#   Provide content of template item. Specify only one of `source` or `content`.
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
