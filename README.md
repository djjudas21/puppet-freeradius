# puppet-freeradius

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
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
of the settings to increase flexibility. Patches are welcome.

### Resources

#### `freeradius::attr`

Install arbitrary attribute filters from a flat flit. These are installed in `/etc/raddb/attr.d`

```
freeradius::attr { 'eduroamlocal':
  source => 'puppet:///modules/site_freeradius/eduroamlocal',
}
```

#### `freeradius::client`

Define RADIUS clients as seen in `clients.conf`

```
freeradius::client { "localhost-${::hostname}-lo":
  ip        => '127.0.0.1',
  secret    => 'testing123',
  shortname => 'localhost',
  nastype   => 'other',
  }
```

 * `ip` Default: `undef`. The IP address of the client.  For IPv6, use `ipv6addr`. `ip` and `ip6` are mutually exclusive but one must be supplied.
 * `ip6` Default: `undef`. The IPv6 address of the client. `ip` and `ip6` are mutually exclusive but one must be supplied.
 * `net` Default: `undef`. The netmask of the client, specified as an integer, e.g. `24`
 * `shortname` required. A short alias that is used in place of the IP address or fully qualified hostname provided in the first line of the section.
 * `secret` required. The RADIUS shared secret used for communication between the client/NAS and the RADIUS server.
 * `server` Default: `undef`
 * `virtual_server` Default: `undef`. The virtual server that traffic from this client should be sent to.
 * `nastype` Default: `undef`. The nastype attribute is used to tell the checkrad.pl script which NAS-specific method it should use when checking simultaneous use.
 * `netmask` Default: `undef`. The netmask of the client, specified as an integer, e.g. `24`
 * `redirect` Default: `undef`
 * `port` Default: `undef`. The UDP port that this virtual server should listen on. Leave blank if this client is not tied to a virtual server.
 * `srcip` Default: `undef`

#### `freeradius::config`

Install arbitrary config snippets from a flat file. These are installed in `/etc/raddb/conf.d`

```
freeradius::config { 'realm-checks.conf':
  source => 'puppet:///modules/site_freeradius/realm-checks.conf',
}
```

#### `freeradius::instantiate`

Instantiate a module that is not automatically instantiated.

```
freeradius::instantiate { 'mymodule': }
```

#### `freeradius::module`

Install a module from a flat file.

```
freeradius::module { 'buffered-sql':
  source => 'puppet:///modules/site_freeradius/buffered-sql',
}
```

#### `freeradius::policy`

Install a policy from a flat file.

```
freeradius::policy { 'my-policies':
  source => 'puppet:///modules/site_freeradius/my-policies',
}
```

#### `freeradius::script`

Install a helper script, e.g. which might be called upon by a virtual server. These are
placed in `/etc/raddb/scripts` and are not automatically included by the server.

```
freeradius::site { 'myperlscript.pl':
  source => 'puppet:///modules/site_freeradius/myperlscript.pl',
}
```

#### `freeradius::site`

Install a virtual server (a.k.a. site) from a flat file. Sites are install directly
into `/etc/raddb/sites-enabled`

```
freeradius::site { 'inner-tunnel':
  source => 'puppet:///modules/site_freeradius/inner-tunnel',
}
```

#### `freeradius::statusclient`

Define RADIUS clients, specifically to connect to the status server for monitoring.
Very similar usage to `freeradius::client` but with fewer options.

 * `ip` Default: `undef`. The IP address of the client.  For IPv6, use `ipv6addr`. `ip` and `ip6` are mutually exclusive but one must be supplied.
 * `ip6` Default: `undef`. The IPv6 address of the client. `ip` and `ip6` are mutually exclusive but one must be supplied.
 * `secret` required. The RADIUS shared secret used for communication between the client/NAS and the RADIUS server.
 * `port` Default: `undef`. The UDP port that this virtual server should listen on. Leave blank if this client is not tied to a virtual server.
 * `shortname` required. A short alias that is used in place of the IP address or fully qualified hostname provided in the first line of the section.


## Limitations

This module is targeted at FreeRADIUS 2.x running on CentOS 6. It has not been tested
on other distributions, but might work. It has not been tested on FreeRADIUS 3.x and
almost certainly won't work without modification.

It was written with Puppet 3.6 but should be quite agnostic to new versions of Puppet.

## Development

This module was written primarily for internal use - features we haven't needed to
use probably haven't been written. Please send pull requests with new features and
bug fixes. You are also welcome to file issues but I make no guarantees of
development effort if the features aren't useful to my employer.

## Release Notes

