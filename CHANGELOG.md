# Changelog

## [1.0.0] - 2026-01-12

First release under new maintainer (tobixen). Major modernization of the module.

### Changed
- **Breaking**: Now requires Puppet 7 or 8 (dropped support for Puppet 3-6)
- **Breaking**: `daily_restarts` now defaults to `false` everywhere (was `true` on RedHat)
- Replaced cron-based scheduling with systemd timers (opt-in via `manage_retention` and `daily_restarts`)
- Updated to use structured facts (`$facts['os']['family']`) instead of legacy top-scope facts
- Consolidated all config templates into single `atop.erb` with both modern and legacy variables
- Replaced Travis CI with GitHub Actions

### Added
- New `manage_retention` parameter to optionally manage log cleanup via systemd timer
- rspec-puppet tests
- Automatic cleanup of old cron jobs when upgrading from previous versions
- Config file now includes legacy variables (INTERVAL, OUTFILE) for compatibility with hybrid systemd/sysvinit setups

### Fixed
- Critical bug: params class was incorrectly named `ms2base::atop::params`

### Removed
- Support for Puppet 3, 4, 5, 6
- OS-specific templates (now single universal template)
