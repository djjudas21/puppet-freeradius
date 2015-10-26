# freeradius

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Classes](#classes)
       * [`freeradius`](#freeradius)
       * [`freeradius::status_server`](#freeradiusstatus_server)
       * [`freeradius::control_socket`](#freeradiuscontrol_socket)
    * [Resources](#resources)
       * [`freeradius::attr`](#freeradiusattr)
       * [`freeradius::blank`](#freeradiusblank)
       * [`freeradius::cert`](#freeradiuscert)
       * [`freeradius::client`](#freeradiusclient)
       * [`freeradius::config`](#freeradiusconfig)
       * [`freeradius::dictionary`](#freeradiusdictionary)
       * [`freeradius::home_server`](#freeradiushomeserver)
       * [`freeradius::home_server_pool`](#freeradiushomeserverpool)
       * [`freeradius::instantiate`](#freeradiusinstantiate)
       * [`freeradius::ldap`](#freeradiusldap)
       * [`freeradius::module`](#freeradiusmodule)
       * [`freeradius::policy`](#freeradiuspolicy)
       * [`freeradius::realm`](#freeradiusrealm)
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
Use of the control_socket parameter in the freeradius class is deprecated. Use the `freeradius::control_socket` class instead.

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

#### `freeradius::status_server`

The `freeradius::status_server` class enabled the [status server](http://wiki.freeradius.org/config/Status).
To remove the status server, do not include this class and the server will be removed.

##### `secret`
The shared secret for the status server. Required.

##### `port`
The port to listen for status requests on. Default: `18121`

##### `listen`
The address to listen on. Defaults to listen on all addresses but you could set this to `$::ipaddress` or `127.0.0.1`.  Default: `*`

```puppet
  # Enable status server
  class { 'freeradius::status_server':
    port   => '18120',
    secret => 't0pSecret!',
  }
```

#### `freeradius::control_socket`

The `freeradius::control_socket` class enables the control socket which can be used with [RADMIN](http://freeradius.org/radiusd/man/radmin.html).
To remove the control socket, do not include this class and the socket will be removed.

##### `mode`
Whether the control socket should be read-only or read-write. Choose from `ro`, `rw`. Default: `ro`.

```puppet
  # Enable control socket
  class { 'freeradius::control_socket':
    mode => 'ro',
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

#### `freeradius::blank`

Selectively blank certain stock config files that aren't required. This is preferable to deleting them
because the package manager will replace certain files next time the package is upgraded, potentially
causing unexpected behaviour.

The resource title should be the relative path from the FreeRADIUS config directory to the file(s) you
want to blank. You can pass multiple files in an array.

```puppet
freeradius::blank { 'sites-enabled/default': }

freeradius::blank { [
  'sites-enabled/default',
  'eap.conf',
]: }
```

#### `freeradius::cert`

Install certificates as provided. These are installed in `/etc/raddb/certs`. Beware that any certificates *not* deployed by Puppet will be purged from this directory.

```puppet
freeradius::cert { 'mycert.pem':
  source => 'puppet:///modules/site_freeradius/mycert.pem',
  type   => 'key',
}
```

```puppet
freeradius::cert { 'mycert.pem':
  content => '<your key/cert content here>',
  type    => 'key',
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

```puppet
freeradius::config { 'realm-checks.conf':
  content => template('your_template),
}
```

#### `freeradius::dictionary`

Install custom dictionaries without breaking the default FreeRADIUS dictionary. Custom dictionaries are installed in `/etc/raddb/dictionary.d` and automatically included in the global dictionary.

```puppet
freeradius::dictionary { 'mydict':
  source => 'puppet:///modules/site_freeradius/dictionary.mydict',
}
```
#### `freeradius::home_server`

This section defines a "Home Server" which is another RADIUS server that gets sent proxied requests.

##### `secret`

The shared secret use to "encrypt" and "sign" packets between FreeRADIUS and the home server.

##### `type`

Home servers can be sent Access-Request packets or Accounting-Request packets. Allowed values are:
* `auth` Handles Access-Request packets
* `acct`  Handles Accounting-Request packets
* `auth+acct` Handles Access-Request packets at "port" and Accounting-Request packets at "port + 1"
* `coa` Handles CoA-Request and Disconnect-Request packets.

Default: `auth`

##### `ipaddr`

IPv4 address or hostname of the home server. Specify one of `ipaddr`, `ipv6addr` or `virtual_server`

##### `ipv6addr`

IPv6 address or hostname of the home server. Specify one of `ipaddr`, `ipv6addr` or `virtual_server`

##### `virtual_server`

If you specify a virtual_server here, then requests will be proxied internally to that virtual server.
These requests CANNOT be proxied again, however. The intent is to have the local server handle packets
when all home servers are dead. Specify one of `ipaddr`, `ipv6addr` or `virtual_server`

##### `port`

The port to which packets are sent. Usually 1812 for type "auth", and  1813 for type "acct".
Older servers may use 1645 and 1646. Use 3799 for type "coa" Default: `1812`

##### `proto`
The transport protocol. If unspecified, defaults to "udp", which is the traditional
RADIUS transport. It may also be "tcp", in which case TCP will be used to talk to
this home server. Default: `udp`


#### `freeradius::home_server_pool`

##### `home_server`

An array of one or more home servers. The names of the home servers are NOT the hostnames, but the names
of the sections. (e.g. `home_server foo {...}` has name "foo".

Note that ALL home servers listed here have to be of the same type. i.e. they all have to be "auth", or they all have to
be "acct", or they all have to be "auth+acct".


##### `type`

The type of this pool controls how home servers are chosen.

* `fail-over` the request is sent to the first live home server in the list.  i.e. If the first home server is marked "dead", the second one is chosen, etc.
* `load-balance` the least busy home server is chosen For non-EAP auth methods, and for acct packets, we recommend using "load-balance". It will ensure the highest availability for your network. 
* `client-balance` the home server is chosen by hashing the source IP address of the packet. This configuration is most useful to do simple load balancing for EAP sessions
* `client-port-balance` the home server is chosen by hashing the source IP address and source port of the packet.
* `keyed-balance` the home server is chosen by hashing (FNV) the contents of the Load-Balance-Key attribute from the control items.

The default type is `fail-over`.

##### `virtual_server`

A `virtual_server` may be specified here.  If so, the "pre-proxy" and "post-proxy" sections are called when
the request is proxied, and when a response is received.

##### `fallback`

If ALL home servers are dead, then this "fallback" home server is used. If set, it takes precedence over any realm-based
fallback, such as the DEFAULT realm.

For reasons of stability, this home server SHOULD be a virtual server. Otherwise, the fallback may itself be dead!


#### `freeradius::instantiate`

Instantiate a module that is not automatically instantiated.

```puppet
freeradius::instantiate { 'mymodule': }
```

#### `freeradius::ldap`

Configure LDAP support for FreeRADIUS

##### `identity`
LDAP account for searching the directory. Required.

##### `password`
Password for the `identity` account. Required.

##### `basedn`
Unless overridden in another section, the dn from which all searches will start from. Required.

##### `server`
Hostname of IP address of the LDAP server. Note that this needs to match the name(s) in the LDAP server
certificate, if you're using ldaps. Default: `localhost`

##### `port`
Port to connect to the LDAP server on. Default: `389`

##### `uses`
How many times the connection can be used before being re-established. This is useful for things
like load balancers, which may exhibit sticky behaviour without it. `0` is unlimited. Default: `0`

##### `idle`
Sets the idle time before keepalive probes are sent. Default `60`

This option may not be supported by your LDAP library. If this configuration entry appears in the
output of `radiusd -X` then it is supported. Otherwise, it is unsupported and changing it will do nothing.

##### `probes`
Sets the maximum number of keepalive probes TCP should send before dropping the connection. Default: `3`

This option may not be supported by your LDAP library. If this configuration entry appears in the
output of `radiusd -X` then it is supported. Otherwise, it is unsupported and changing it will do nothing.

##### `interval`
Setss the interval in seconds between individual keepalive probes. Default: `3`

This option may not be supported by your LDAP library. If this configuration entry appears in the
output of `radiusd -X` then it is supported. Otherwise, it is unsupported and changing it will do nothing.

##### `timeout`
Number of seconds to wait for LDAP query to finish. Default: `10`

##### `start`
Connections to create during module instantiation. If the server cannot create specified number of
connections during instantiation it will exit. Set to 0 to allow the server to start without the
directory being available. This option only works with FR3; setting it on FR2 will have no effect.
Default: `${thread[pool].start_servers}`

##### `min`
Minimum number of connections to keep open. This option only works with FR3; setting it on FR2 will have no effect.
Default: `${thread[pool].min_spare_servers}`

##### `max`
Maximum number of connections. Default: `${thread[pool].max_servers}`

##### `spare`
Spare connections to be left idle. This option only works with FR3; setting it on FR2 will have no effect.
Default: `${thread[pool].max_spare_servers}`

##### `starttls`
Set this to 'yes' to use TLS encrypted connections to the LDAP database by using the StartTLS extended operation.
The StartTLS operation is supposed to be used with normal ldap connections instead of using ldaps (port 636) connections

Default: `no`

##### `cafile`
Path to CA cert file for TLS

##### `certfile`
Path to cert file for TLS

##### `keyfile`
Path to key file for TLS

##### `requirecert`
Certificate Verification requirements. Choose from:
'never' (do not even bother trying)
'allow' (try, but don't fail if the certificate cannot be verified)
'demand' (fail if the certificate does not verify)
'hard'  (similar to 'demand' but fails if TLS cannot negotiate)

Default: `allow`


#### `freeradius::module`

Install a module from a flat file.

```puppet
freeradius::module { 'buffered-sql':
  source => 'puppet:///modules/site_freeradius/buffered-sql',
}
```

```puppet
freeradius::module { 'buffered-sql':
  content => template('some_template.erb)',
}
```

#### `freeradius::policy`

Install a policy from a flat file.

```puppet
freeradius::policy { 'my-policies':
  source => 'puppet:///modules/site_freeradius/my-policies',
}
```

#### `freeradius::realm`

Define a realm in `proxy.conf`. Realms point to pools of home servers.

##### `virtual_server`

Set this to "proxy" requests internally to a virtual server. The pre-proxy and post-proxy sections are run just as with any
other kind of home server.  The virtual server then receives the request, and replies, just as with any other packet.
Once proxied internally like this, the request CANNOT be proxied internally or externally.

##### `auth_pool`

For authentication, the `auth_pool` configuration item should point to a `home_server_pool` that was previously
defined.  All of the home servers in the `auth_pool` must be of type `auth`.

##### `acct_pool`

For accounting, the `acct_pool` configuration item should point to a `home_server_pool` that was previously
defined.  All of the home servers in the `acct_pool` must be of type `acct`.

##### `pool`

If you have a `home_server_pool` where all of the home servers are of type `auth+acct`, you can just use the `pool`
configuration item, instead of specifying both `auth_pool` and `acct_pool`.

##### `nostrip`

Normally, when an incoming User-Name is matched against the realm, the realm name is "stripped" off, and the "stripped"
user name is used to perform matches.If you do not want this to happen, set this to `true`. Default: `false`.


#### `freeradius::script`

Install a helper script, e.g. which might be called upon by a virtual server. These are
placed in `/etc/raddb/scripts` and are not automatically included by the server.

```puppet
freeradius::script{ 'myperlscript.pl':
  source => 'puppet:///modules/site_freeradius/myperlscript.pl',
}
```

#### `freeradius::site`

Install a virtual server (a.k.a. site) from a flat file. Sites are installed directly
into `/etc/raddb/sites-enabled`. Any files in this directory that are *not* managed by
Puppet will be removed.

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

##### `port`

TCP port to connect to the database. Default: `3306`.

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

##### `lifetime`

Default: `0`. Lifetime of an SQL socket. If you are having network issues such as TCP sessions expiring, you may need to set the socket
lifetime. If set to non-zero, any open connections will be closed `$lifetime` seconds after they were first opened.

##### `max_queries`

Default: `0`. Maximum number of queries used by an SQL socket. If you are having issues with SQL sockets lasting "too long", you can
limit the number of queries performed over one socket. After `$max_qeuries`, the socket will be closed. Use 0 for "no limit".

##### `query_file`

**`query_file` has been deprecated - use `custom_query_file` instead**

Default: `sql/${database}/dialup.conf`. Relative path to the file which contains your SQL queries. By
default, points to the `dialup.conf` specific to your database engine, so leave this blank if you are
using stock queries.

If you need to use custom queries, it is recommended that you deploy your query file using
`freeradius::script` to install the file into `/etc/raddb/scripts/custom_dialup.conf` and then
set `query_file` to `scripts/custom_dialup.conf`.

##### `custom_query_file`

Default: `null`. Puppet fileserver path to a file which contains your SQL queries, i.e. `dialup.conf`. This
option is intended to be a replacment for `query_file`, which requires separate deployment of the file. This
option allows you to specify a Puppet-managed custom `dialup.conf` which is installed and loaded automatically.
`query_file` must be left blank if you use `custom_query_file`.

##### `acct_table1`

If you want both stop and start records logged to the same SQL table, leave this as is.  If you want them in
different tables, put the start table in `$acct_table1` and stop table in `$acct_table2`. Default : `radacct`

##### `acct_table2`

If you want both stop and start records logged to the same SQL table, leave this as is.  If you want them in
different tables, put the start table in `$acct_table1` and stop table in `$acct_table2`. Default : `radacct`

##### `postauth_table`

Table for storing data after authentication

##### `authcheck_table`

Default: `radcheck`

##### `authreply_table`

Default: `radreply`

##### `groupcheck_table`

Default: `radgroupcheck`

##### `groupreply_table`

Default: `radgroupreply`

##### `usergroup_table`

Table to keep group info. Default: `radusergroup`

##### `read_groups`

If set to `yes` (default) we read the group tables. If set to `no` the user MUST have `Fall-Through = Yes`
in the radreply table. Default: `yes`.

##### `deletestalesessions`

Remove stale session if checkrad does not see a double login. Default: `yes`.

##### `sqltrace`

Print all SQL statements when in debug mode (-x). Default: `no`.

##### `sqltracefile`

Location for SQL statements to be stored if `$sqltrace = yes`. Default:
`${logdir}/sqltrace.sql`

##### `connect_failure_retry_delay`

Number of seconds to dely retrying on a failed database connection (per socket). Default: `60`.

##### `nas_table`

Table to keep radius client info. Default: `nas`.

#### `readclients`

Set to `yes` to read radius clients from the database (`$nas_table`) Clients will ONLY be read on server startup. For performance
and security reasons, finding clients via SQL queries CANNOT be done "live" while the server is running. Default: `no`.

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

### 0.4.5

 * Tweak wildcard matching on logrotate config

### 0.4.4

 * Fix bug displaying deprecation notice and update documentation to reflect this

### 0.4.3

 * Manage log rotation with [rodjek/logrotate](https://forge.puppetlabs.com/rodjek/logrotate) instead of deploying flat files

### 0.4.2

 * Provide new SQL option custom_query_file

### 0.4.1

 * Cease management of custom logging modules `logtofile` and `logtosyslog` since it does not make sense to manage these globally 
 * Purge instantiation of unused modules

### 0.4.0

 * Move control_socket into its own class and add parameters
 * Improve the way the status_server is added or removed
 * Delete all unmanaged sites from sites-available

### 0.3.8

 * Purge all non-managed sites

### 0.3.7

 * Minor linting of code to improve score
 * Minor linting of metadata to improve score

### 0.3.6

 * Bugfixes and feature improvements in `freeradius::sql`

### 0.3.5

 * Add ability to customise SQL socket lifetimes
 * Purge all non-managed clients
 * Add defined type to blank out unneeded config files without deleting them

### 0.3.4

 * Correctly pass template content to control-socket

### 0.3.3

 * The default behaviour is now to purge anything in ${confdir}/certs that is not managed by Puppet

### 0.3.2

 * Various improvements to support Debian family
 * Optional content parameters in various resources

### 0.3.1

 * Fix a bug which prevents the module from working properly on Debian/Ubuntu (thanks @diranged)

### 0.3.0

 * Add `ensure` parameter to all defined types

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

