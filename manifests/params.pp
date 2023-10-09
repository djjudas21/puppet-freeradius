# Default parameters for freeradius
class freeradius::params {
  # Make an educated guess which version of FR we are running, based on the OS
  case $::operatingsystem {
    /RedHat|CentOS|Rocky|AlmaLinux/: {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        5       => '2',
        6       => '2',
        7       => '3',
        8       => '3',
        9       => '3',
        default => '3',
      }
    }
    'Debian': {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        6       => '2',
        7       => '2',
        8       => '2',
        9       => '3',
        default => '3',
      }
    }
    'Fedora': {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        21      => '3',
        22      => '3',
        23      => '3',
        default => '3',
      }
    }
    'Ubuntu': {
      $fr_guessversion = $::operatingsystemmajrelease ? {
        '14.04' => '2',
        '14.10' => '2',
        '15.04' => '2',
        '15.10' => '2',
        '18.04' => '3',
        '20.04' => '3',
        '22.04' => '3',
        default => '2',
      }
    }
    default: {
      fail("OS ${::operatingsystem} is not supported")
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
    'Debian' => true,
    default  => false,
  }

  # Default pid file location
  $fr_pidfile = "/var/run/${fr_service}/${fr_service}.pid"

  # Default base path for FreeRADIUS configs
  case $::osfamily {
    'RedHat': {
      $fr_basepath = '/etc/raddb'
      $fr_raddbdir = "\${sysconfdir}/raddb"
    }
    'Debian': {
      $fr_basepath = $::operatingsystemmajrelease ? {
        '9'          => '/etc/freeradius/3.0',
        '10'         => '/etc/freeradius/3.0',
        '11'         => '/etc/freeradius/3.0',
        'buster/sid' => '/etc/freeradius/3.0',
        '18.04'      => '/etc/freeradius/3.0',
        '20.04'      => '/etc/freeradius/3.0',
        '22.04'      => '/etc/freeradius/3.0',
        default      => '/etc/freeradius',
      }
      $fr_raddbdir = $::operatingsystemmajrelease ? {
        '9'          => "\${sysconfdir}/freeradius/3.0",
        '10'         => "\${sysconfdir}/freeradius/3.0",
        '11'         => "\${sysconfdir}/freeradius/3.0",
        'buster/sid' => "\${sysconfdir}/freeradius/3.0",
        '18.04'      => "\${sysconfdir}/freeradius/3.0",
        '20.04'      => "\${sysconfdir}/freeradius/3.0",
        '22.04'      => "\${sysconfdir}/freeradius/3.0",
        default      => "\${sysconfdir}/freeradius",
      }
    }
    default: {
      $fr_basepath = '/etc/raddb'
      $fr_raddbdir = "\${sysconfdir}/raddb"
    }
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

  $fr_libdir = $::osfamily ? {
    'RedHat' => '/usr/lib64/freeradius',
    'Debian' => '/usr/lib/freeradius',
    default  => '/usr/lib64/freeradius',
  }

  $fr_db_dir = $::osfamily ? {
    'Debian' => "\${raddbdir}",
    default  => "\${localstatedir}/lib/radiusd",
  }

  $radacctdir = "\${logdir}/radacct"

  # Default radsniff environment file location
  $fr_radsniff_envfile = $::osfamily ? {
    'RedHat' => '/etc/sysconfig/radsniff',
    'Debian' => '/etc/defaults/radsniff',
    default  => undef,
  }

  # Default radsniff pid file location
  $fr_radsniff_pidfile = "/var/run/${fr_service}/radsniff.pid"
}
