## Changelog

### 3.7.0
  * Add support for Ubuntu 18.04 LTS (thanks @rogermartensson)
  * Improved support for Debian 9 (thanks @carlgarner)
  * Improvements to huntgroups (thanks @amateo)
  * General bug fixes (thanks @infracaninophile, @coreone and @olivierlm))

### 3.6.0
  * Add support for Debian 9 (thanks @its-not-a-bug-its-a-feature)

### 3.5.0
  * Add support for huntgroups (thanks @sts and @phaer)

### 3.4.3
  * Fix missing notify that caused problems when adding a new virtual server in `sites_available`

### 3.4.1
  * Fix calling syntax for logrotate
  * Add param `package_ensure`

### 3.4.0
  * Fix bug with modules that have ensure => absent
  * Fix bug with module::files where content and source
  * Fix bug with path of krb5 module
  * Manage parameter `allow_expired_crl`
  * Clean up comments in templates to reduce the size

### 3.3.0
  * Deploy modules to `mods_available` and symlink to `mods_enabled`
  * Deploy modules to `sites_available` and symlink to `sites_enabled`

### 3.2.0
  * Warn instead of failing if the FR version is not 3.x
  * Update logrotate module dependency
  * Add PostgreSQL support
  * Fix bug with templating home servers in Puppet 4
  * Fix bug with logrotate postrotate on non Red Hat distros

### 3.1.0
  * Provide facility to enable/disable specific EAP types in `freeradius::module::eap`

### 3.0.0
  * More parameters available for `freeradius::client`
  * Allow management of `freeradius::dictionary` with `source` or `content`
  * Enable status checks for `freeradius::home_server`
  * More configurable options for `freeradius` base class
  * More sensible permissions on various config files
  * Refactor `freeradius::ldap` as `freeradius::module::ldap` and add more params
  * Create `freeradius::listen` to manage arbitrary listeners
  * Create `freeradius::module::detail` to configure detail loggers
  * Create `freeradius::module::eap` to manage instantiations of the `eap` module
  * Create `freeradius::module::files` to manage instantiations of the `files` module
  * Create `freeradius::module::huntgroup` to manage huntgroups
  * Create `freeradius::module::ippool` to manage ippool resources
  * Create `freeradius::module::linelog` to configure linelog loggers
  * Create `freeradius::module::preprocess` to manage instantiations of the `preprocess` module
  * Fix some compatibility problems with Debian/Ubuntu systems
  * Allow `freeradius::site` resources (virtual servers) to have their content managed other than just with flat files
  * Add more options to `freeradius::sql`
  * Add various types of validation for Puppet 4

### 2.3.1
  * Fix bug with log rotation throwing errors when radiusd is not running

### 2.3.0
  * Add support to configure virtual modules for fail-over and load-balancing

### 2.2.0
  * Add support to configure the krb5 module

### 2.1.4
  * Fix compatibility with Puppet 4

### 2.1.3
  * Fix compatibility with Puppet 4

### 2.1.2
  * Write out ldap config with different syntax for FreeRADIUS 3.0.x and 3.1.x when using multiple servers

### 2.1.1

  * Fix bug with the facts not reporting version numbers accurately

### 2.1.0

  * Various changes to preserve stock modules in a FreeRADIUS installation and be able to toggle them

### 2.0.1

  * Fix up LDAP template to allow better compatibility with FreeRADIUS 3.1.x

### 2.0.0

  * Drop support for FreeRADIUS 2.x, enabling us to keep the codebase tidier

### 1.3.0

  * Add support for defining config templates

### 1.2.6

  * Fix a bug that now enables sqltrace (sqllog) to work on FR3

### 1.2.5

  * Switch to use [saz/rsyslog](https://forge.puppetlabs.com/saz/rsyslog) to manage syslog rules

### 1.2.4

  * Start with just 1 SQL socket by default to avoid overloading the SQL server

### 1.2.3

  * Make facts fail gracefully if radiusd is not installed

### 1.2.2

  * Fix a bug that stops statusclients from working

### 1.2.1

  * Fix a bug that prevent 1.2.0 from working on FreeRADIUS 2

### 1.2.0

 * Deprecate `netmask` parameter from `freeradius::client`

### 1.1.0

 * Add support to supply an array of multiple LDAP servers

### 1.0.4

 * Make an educated guess about the version of FR when the fact is unavailable (e.g. on the first Puppet run)

### 1.0.3

 * Iron out a couple of issues with LDAP compatibility with Active Directory

### 1.0.2

 * Fixed a bug that prevented LDAP from working on any port except 389

### 1.0.1

 * Fixed a bug that caused an error when no proxy config items were defined

### 1.0.0

 * Support for FreeRADIUS 3
 * Native support for managing the LDAP module
 * Native support for configuring realms (via realms, home_server and home_server_pool)
 * Improved handling of attribute filtering
 * Improved handling of SQL support

This release retains support for FreeRADIUS 2 but some of the parameters have changed so you will probably need to make changes to the way you use this module. Upgrade on a dev system first!

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

