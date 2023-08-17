# @summary Sasl type of FreeRADIUS
type Freeradius::Sasl = Struct[
  {
    mech  => Optional[String],
    proxy => Optional[String],
    realm => Optional[String],
  },
]
