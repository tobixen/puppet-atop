# atop

Puppet module for installing and configuring atop, the ASCII full-screen performance monitor for Linux.

## Description

This module manages the installation, configuration, and service state of [atop](https://www.atoptool.nl/), a tool for monitoring system resources and process activity. Atop provides detailed insights into CPU, memory, disk, and network usage, with the ability to log historical data for later analysis.

## Setup

### What atop affects

- Installs the `atop` package
- Manages the atop configuration file (`/etc/default/atop` or `/etc/sysconfig/atop`)
- Manages the atop service

Optionally it can also manage log retation and daily service restart.  This was needed in the olden times.  My impression is that all modern distros takes care of this out of the box.  The elaborate but outdated list of what distro versions it is needed for and not has been removed as of version 1.0.0.  I may consider to reinsert it.

### Beginning with atop

Install atop with the service disabled (default):

```puppet
include atop
```

## Usage

### Recommended production configuration

```puppet
class { 'atop':
  service  => true,
  interval => 30,
  keepdays => 28,
}
```

**Note on interval**: The package default of 600 seconds (10 minutes) is often too long to capture short-lived resource starvation events. A 30-second interval is recommended for production systems - this ensures that problems like memory pressure, CPU spikes, or I/O bottlenecks are logged before the system becomes unresponsive or triggers the OOM killer.  The drawback is that the log fies may become quite big.

### All parameters

```puppet
class { 'atop':
  package_name     => 'atop',           # Package name to install
  service_name     => 'atop',           # Service name to manage
  service          => true,             # Enable and start the service
  interval         => 30,               # Logging interval in seconds
  logpath          => '/var/log/atop',  # Directory for log files
  keepdays         => 28,               # Days to retain logs (sets LOGGENERATIONS)
  manage_retention => false,            # Create cleanup timer (for old distros)
  daily_restarts   => false,            # Create restart timer (for old distros)
}
```

## Reference

### Parameters

#### `package_name`
The package name to install. Default: `atop`

#### `service_name`
The service name to manage. Default: `atop`

#### `service`
Whether to enable and start the atop service. Default: `false`

#### `interval`
Interval between snapshots in seconds. Default: `600`. **Recommendation**: Use `30` for production systems to capture short-lived resource issues.

#### `logpath`
Directory where atop logs are saved. Default: `/var/log/atop`

#### `keepdays`
Number of days to retain log files. Sets LOGGENERATIONS in the config file. Default: `undef` (use package default). Modern atop packages handle retention automatically based on this value.

#### `manage_retention`
If `true`, create a systemd timer to clean up old logs and disable logrotate. Only needed on old distros where the package doesn't handle retention properly. Default: `false`

#### `daily_restarts`
If `true`, create a systemd timer to restart atop daily. Only needed on old distros with buggy log rotation that doesn't release the old log file. Default: `false`

## Limitations

This module should work on any Linux distribution with systemd where atop is available, including:

- Red Hat Enterprise Linux / CentOS / Rocky / AlmaLinux
- Debian / Ubuntu
- Arch Linux

Requires Puppet 7 or 8.

## Development

Contributions are welcome! Please submit issues and pull requests at:
https://github.com/tobixen/puppet-atop

### Running tests

```bash
bundle install
bundle exec rake test
```

## License

MIT License - see LICENSE file for details.

## History

This module is a fork of [gnubila-france/puppet-atop](https://github.com/gnubila-france/puppet-atop), which is no longer maintained.
