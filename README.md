# freeradius

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)

## Overview

This module installs and configures [FreeRADIUS](http://freeradius.org/) server
on Linux. It supports FreeRADIUS 3.x only. It was designed with CentOS in mind
but should work on other distributions.

This module requires Puppet 4.0.0 or greater. Puppet 3.x was
[discontinued](https://puppet.com/misc/puppet-enterprise-lifecycle) at
the end of 2016.

| `jgazeley/freeradius` | FreeRADIUS  |
| --------------------- | ----------- |
| 3.x                   | 3.x         |
| 2.x                   | 3.x         |
| 1.x                   | 2.x and 3.x |
| 0.x                   | 2.x         |

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

See [REFERENCE.md](https://github.com/djjudas21/puppet-freeradius/blob/main/REFERENCE.md)

## Limitations

This module is targeted at FreeRADIUS 3.x running on CentOS 7. It will not work on
FreeRADIUS 2.x. It has not been thoroughly tested on other distributions, but
might work. Likely sticking points with other distros are the names of packages,
services and file paths.

This module requires Puppet 4 or greater.
