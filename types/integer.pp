# @summary Integer in FreeRADIUS
type Freeradius::Integer = Variant[
  Pattern[/^\$\{.+\}$/],
  Integer,
]
