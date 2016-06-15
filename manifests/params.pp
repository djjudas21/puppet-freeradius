# Default parameters for freeradius
class freeradius::params {

  # Make an educated guess which version of FR we are running, based on the OS
  case $::operatingsystem {
    /RedHat|CentOS/: {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        5       => 2,
        6       => 2,
        7       => 3,
        default => 3,
      }
    }
    'Debian': {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        6       => 2,
        7       => 2,
        8       => 2,
        default => 2,
      }
    }
    'Fedora': {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        21      => 3,
        22      => 3,
        23      => 3,
        default => 3,
      }
    }
    'Ubuntu': {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        '14.04' => 2,
        '14.10' => 2,
        '15.04' => 2,
        '15.10' => 2,
        default => 2,
      }
    }
  }

  # Use the FR version fact if defined, otherwise use our best estimate from above
  if getvar('::freeradius_maj_version') {
    $fr_version = $::freeradius_maj_version
  } else {
    $fr_version = $fr_guessversion
  }

  # Name of FreeRADIUS package
  $fr_package = $::osfamily ? {
    'RedHat' => 'freeradius',
    'Debian' => 'freeradius',
    default  => 'freeradius',
  }

  # Name of wpa_supplicant package
  $fr_wpa_supplicant = $::osfamily ? {
    'RedHat' => 'wpa_supplicant',
    'Debian' => 'wpasupplicant',
    default  => 'wpa_supplicant',
  }

  # Name of FreeRADIUS service
  $fr_service = $::osfamily ? {
    'RedHat' => 'radiusd',
    'Debian' => 'freeradius',
    default  => 'radiusd',
  }

  # Whether the FreeRADIUS init.d startup script has a status setting or not
  $fr_service_has_status = $::osfamily ? {
    'RedHat' => true,
    'Debian' => false,
    default  => false,
  }

  # Default base path for FreeRADIUS configs
  $fr_basepath = $::osfamily ? {
    'RedHat' => '/etc/raddb',
    'Debian' => '/etc/freeradius',
    default  => '/etc/raddb',
  }

  # Default module dir
  $fr_moduledir = $fr_version ? {
    '2'       => 'modules',
    '3'       => 'mods-enabled',
    default   => 'modules',
  }

  # Default module path
  $fr_modulepath = "${fr_basepath}/${fr_moduledir}"

  # Default module config dir
  $fr_modconfigdir = $fr_version ? {
    '2'       => 'conf.d',
    '3'       => 'mods-config',
    default   => 'conf.d',
  }

  # Default module config path
  $fr_moduleconfigpath = "${fr_basepath}/${fr_modconfigdir}"

  # Path for FreeRADIUS logs
  $fr_logpath = $::osfamily ? {
    'RedHat' => '/var/log/radius',
    'Debian' => '/var/log/freeradius',
    default  => '/var/log/radius',
  }

  # FreeRADIUS user
  $fr_user = $::osfamily ? {
    'RedHat' => 'radiusd',
    'Debian' => 'freerad',
    default  => 'radiusd',
  }

  # FreeRADIUS group
  $fr_group = $::osfamily ? {
    'RedHat' => 'radiusd',
    'Debian' => 'freerad',
    default  => 'radiusd',
  }

  # Privileged winbind user
  $fr_wbpriv_user = $::osfamily ? {
    'RedHat' => 'wbpriv',
    'Debian' => 'winbindd_priv',
    default  => 'wbpriv',
  }
}
