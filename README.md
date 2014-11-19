# freeradius

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Classes](#classes)
       * [`freeradius`](#freeradius)
    * [Resources](#resources)
       * [`freeradius::attr`](#freeradiusattr)
       * [`freeradius::cert`](#freeradiuscert)
       * [`freeradius::client`](#freeradiusclient)
       * [`freeradius::config`](#freeradiusconfig)
       * [`freeradius::dictionary`](#freeradiusdictionary)
       * [`freeradius::instantiate`](#freeradiusinstantiate)
       * [`freeradius::module`](#freeradiusmodule)
       * [`freeradius::policy`](#freeradiuspolicy)
       * [`freeradius::site`](#freeradiussite)
       * [`freeradius::sql`](#freeradiussql)
       * [`freeradius::statusclient`](#freeradiusstatusclient)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)
6. [Release Notes](#release-notes)

## Overview

This module installs and configures [FreeRADIUS](http://freeradius.org/) server
on Linux. This module was written for use with FreeRADIUS 2.x and has not been
tested with FreeRADIUS 3.x. It was designed with CentOS in mind but should
work on other distributions.

## Module Description

This module installs FreeRADIUS from a distro-provided package and installs a
number of customised config files to enable flexibility. It then provides some
helpers to allow you to easily configure virtual servers (sites), modules, clients
and other config items. Most of these items accept a flat config file which you
supply either as a static file or a template - similar to the `source` and `content`
parameters in Puppet's `file` resource.

This module is designed to make it more straightforward for RADIUS administrators to
deploy RADIUS servers using Puppet. This module does not serve as a wizard and does
not avoid having to have an understanding of FreeRADIUS.


## Usage

This module provides several classes and defined types which take parameters.

### Classes

#### `freeradius`

The `freeradius` class installs the base server. In the early releases, this class does not
have many parameters as most values are hard-coded. I am working on parameterising more
of the global settings to increase flexibility. Patches are welcome.

##### `control_socket`
Enable the `control-socket` virtual server. See also the `radmin` program. Default: `false`

##### `max_requests`
The maximum number of requests which the server keeps track of. This should be 256 multiplied by the number of clients. Default: `4096`

##### `max_servers`
Limit on the total number of servers running. Default: `4096`

##### `mysql_support`
Install support for MySQL. Note this only installs the package. Use `freeradius::sql` to configure SQL support. Default: `false`

##### `perl_support`
Install support for Perl. Default: `false`

##### `utils_support`
Install FreeRADIUS utils. Default: `false`

##### `ldap_support`
Install support for LDAP. Default: `false`

##### `wpa_supplicant`
Install wpa_supplicant utility. Default: `false`

##### `winbind_support`
Add the radius user to the winbind privileged group. You must install winbind separately. Default: `false`.

##### `syslog`
Add a syslog rule (using the `jgazeley/syslog` module). Default: `false`.

```puppet
class { 'freeradius':
  control_socket  => true,
  max_requests    => 4096,
  max_servers     => 4096,
  mysql_support   => true,
  perl_support    => true,
  utils_support   => true,
  wpa_supplicant  => true,
  winbind_support => true,
  syslog          => true,
}
```

### Resources

#### `freeradius::attr`

Install arbitrary attribute filters from a flat file. These are installed in `/etc/raddb/attr.d`

```puppet
freeradius::attr { 'eduroamlocal':
  source => 'puppet:///modules/site_freeradius/eduroamlocal',
}
```

#### `freeradius::cert`

Install certificates as provided. These are installed in `/etc/raddb/certs`

```puppet
freeradius::cert { 'mycert.pem':
  source => 'puppet:///modules/site_freeradius/mycert.pem',
  type   => 'key',
}
```

##### `type`

Set file permissions on the installed certificate differently depending on whether this is a private key or a public certificate. Note that the default is to treat the file as a private key and remove world-readable privileges. Allowable values: `cert`, `key`. Default: `key`.

#### `freeradius::client`

Define RADIUS clients as seen in `clients.conf`

```puppet
freeradius::client { "wlan-controller01":
  ip        => '192.168.0.1',
  secret    => 'testing123',
  shortname => 'wlc01',
  nastype   => 'other',
  port      => '1645-1646',
  firewall  => true,
}
```

##### `ip`
The IP address of the client.  For IPv6, use `ipv6addr`. `ip` and `ip6` are mutually exclusive but one must be supplied. Default: `undef`.

##### `ip6`
The IPv6 address of the client. `ip` and `ip6` are mutually exclusive but one must be supplied. Default: `undef`.

##### `shortname`
A short alias that is used in place of the IP address or fully qualified hostname provided in the first line of the section. Required.

##### `secret`
The RADIUS shared secret used for communication between the client/NAS and the RADIUS server. Required.

##### `virtual_server`
The virtual server that traffic from this client should be sent to. Default: `undef`.

##### `nastype`
The `nastype` attribute is used to tell the `checkrad.pl` script which NAS-specific method it should use when checking simultaneous use. See [`man clients.conf`](http://freeradius.org/radiusd/man/clients.conf.txt) for a list of all options. Default: `undef`.

##### `netmask`
The netmask of the client, specified as an integer, e.g. `24`. Default: `undef`.

##### `port`
The UDP port that this virtual server should listen on. Leave blank if this client is not tied to a virtual server. Currently the port number is only used to create firewall exceptions and you only need to specify it if you set `firewall => true`. Use port range syntax as in [`puppetlabs-firewall`](https://forge.puppetlabs.com/puppetlabs/firewall). Default: `undef`.

##### `firewall`
Create a firewall exception for this virtual server. If this is set to `true`, you must also supply `port` and either `ip` or `ip6`. Default: `false`.

#### `freeradius::config`

Install arbitrary config snippets from a flat file. These are installed in `/etc/raddb/conf.d`

```puppet
freeradius::config { 'realm-checks.conf':
  source => 'puppet:///modules/site_freeradius/realm-checks.conf',
}
```

#### `freeradius::dictionary`

Install custom dictionaries without breaking the default FreeRADIUS dictionary. Custom dictionaries are installed in `/etc/raddb/dictionary.d` and automatically included in the global dictionary.

```puppet
freeradius::dictionary { 'mydict':
  source => 'puppet:///modules/site_freeradius/dictionary.mydict',
}
```

#### `freeradius::instantiate`

Instantiate a module that is not automatically instantiated.

```puppet
freeradius::instantiate { 'mymodule': }
```

#### `freeradius::module`

Install a module from a flat file.

```puppet
freeradius::module { 'buffered-sql':
  source => 'puppet:///modules/site_freeradius/buffered-sql',
}
```

#### `freeradius::policy`

Install a policy from a flat file.

```puppet
freeradius::policy { 'my-policies':
  source => 'puppet:///modules/site_freeradius/my-policies',
}
```

#### `freeradius::script`

Install a helper script, e.g. which might be called upon by a virtual server. These are
placed in `/etc/raddb/scripts` and are not automatically included by the server.

```puppet
freeradius::site { 'myperlscript.pl':
  source => 'puppet:///modules/site_freeradius/myperlscript.pl',
}
```

#### `freeradius::site`

Install a virtual server (a.k.a. site) from a flat file. Sites are installed directly
into `/etc/raddb/sites-enabled`

```puppet
freeradius::site { 'inner-tunnel':
  source => 'puppet:///modules/site_freeradius/inner-tunnel',
}
```

#### `freeradius::sql`

Configure SQL connections. You can define multiple database connections by
invoking this resource multiple times. If you are using MySQL, don't forget to
also set `mysql_support => true` in the base `freeradius` class.

```puppet
freeradius::sql { 'mydatabase':
  database  => 'mysql',
  server    => '192.168.0.1',
  login     => 'radius',
  password  => 'topsecret',
  radius_db => 'radius',
}
```

##### `database`

Default: `undef`. Required. Specify which FreeRADIUS database driver to use. Choose one of `mysql`, `mssql`, `oracle`, `postgresql`

##### `server`

Default: `localhost`. Specify hostname of IP address of the database server.

##### `login`

Default: `radius`. Username to connect to the databae.

##### `password`

Default: `undef`. Required. Password to connect to the database.

##### `radius_db`

Default: `radius`. Name of the database. Normally you should leave this alone. If you are using Oracle then use this instead:
`(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))(CONNECT_DATA=(SID=your_sid)))`.

##### `num_sql_socks`

Default: same as `max_servers`. Number of sql connections to make to the database server. 
Setting this to LESS than the number of threads means that some threads may starve, and
you will see errors like "No connections available and at max connection limit". Setting
this to MORE than the number of threads means that there are more connections than necessary.
Leave blank to set it to the same value as the number of threads.

##### `query_file`

Default: `sql/${database}/dialup.conf`. Relative path to the file which contains your SQL queries. By
default, points to the `dialup.conf` specific to your database engine, so leave this blank if you are
using stock queries.

If you need to use custom queries, it is recommended that you deploy your query file using
`freeradius::script` to install the file into `/etc/raddb/scripts/custom_dialup.conf` and then
set `query_file` to `scripts/custom_dialup.conf`.


#### `freeradius::statusclient`

Define RADIUS clients, specifically to connect to the status server for monitoring.
Very similar usage to `freeradius::client` but with fewer options.

##### `ip`
Default: `undef`. The IP address of the client.  For IPv6, use `ipv6addr`. `ip` and `ip6` are mutually exclusive but one must be supplied.

##### `ip6`
Default: `undef`. The IPv6 address of the client. `ip` and `ip6` are mutually exclusive but one must be supplied.

##### `secret`
required. The RADIUS shared secret used for communication between the client/NAS and the RADIUS server.

##### `port`
Default: `undef`. The UDP port that this virtual server should listen on. Leave blank if this client is not tied to a virtual server.

##### `shortname`
required. A short alias that is used in place of the IP address or fully qualified hostname provided in the first line of the section.


## Limitations

This module is targeted at FreeRADIUS 2.x running on CentOS 6. It has not been tested
on other distributions, but might work. Likely sticking points with other distros are
the names of packages, services and file paths.

This module has not been tested on FreeRADIUS 3.x and almost certainly won't work
without modification. FreeRADIUS 3.x support in this module will come onto the roadmap
at the same time that my employer decides to start looking FreeRADIUS 3.x.

This module was written for use with Puppet 3.6 and 3.7, but should be quite agnostic
to new versions of Puppet.

## Development

This module was written primarily for internal use - features we haven't needed to
use probably haven't been written. Please send pull requests with new features and
bug fixes. You are also welcome to file issues but I make no guarantees of
development effort if the features aren't useful to my employer.

## Release Notes

### 0.2.0

 * Add support for customising `sql.conf` natively by adding `freeradius::sql`

### 0.1.4

 * Fix ambiguity about net/netmask in freeradius::client

### 0.1.3

 * Add support for managing firewall rules automatically
 * Add support for installation certificates & keys
 * Make syslog support an optional component
 * Various bugfixes

### 0.1.2

 * Improved modular installs with optional components
 * Improved support for Debian
 * Clarify dependencies on other modules
 * Lots of bugfixes

### 0.1.0

 * Initial release with support for installing FreeRADIUS and configuring servers, modules, clients and other objects using flat files.
 * Probably works only with FreeRADIUS 2.x
 * Only tested with CentOS 6

