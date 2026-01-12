# @summary Install and configure atop system and process monitor
#
# @see https://github.com/tobixen/puppet-atop
#
# == Class: atop
#
# Allow to install and configure atop.
#
# === Parameters
#
# [*package_name*]
#   Package name, default to atop.
#
# [*service_name*]
#   Service name, default to atop.
#
# [*service*]
#   Enable atop service, default to false.
#
# [*interval*]
#   Interval between snapshots, default to 600.
#
# [*logpath*]
#   Directory were the log will be saved by the service.
#   Default is /var/log/atop.
#
# [*keepdays*]
#   Number of days to keep atop logs. Sets LOGGENERATIONS in config.
#   Default is undef (use package default).
#
# [*manage_retention*]
#   If true, create a systemd timer to clean up old logs and disable
#   logrotate. Only needed on old distros where the package doesn't
#   handle retention properly. Default is false.
#
# [*daily_restarts*]
#   If true, create a systemd timer to restart atop daily. Only needed
#   on old distros with buggy log rotation. Default is false.
class atop (
  $package_name     = $atop::params::package_name,
  $service_name     = $atop::params::service_name,
  $service          = $atop::params::service,
  $interval         = $atop::params::interval,
  $logpath          = $atop::params::logpath,
  $keepdays         = $atop::params::keepdays,
  $manage_retention = $atop::params::manage_retention,
  $daily_restarts   = $atop::params::daily_restarts,
) inherits atop::params {
  $service_state = $service ? {
    true    => 'running',
    default => 'stopped',
  }

  package { $package_name:
    ensure => 'installed',
  } ->
  file { $atop::params::conf_file:
    ensure  => 'file',
    owner   => $atop::params::conf_file_owner,
    group   => $atop::params::conf_file_group,
    mode    => $atop::params::conf_file_mode,
    content => template($atop::params::conf_file_template),
  } ->
  service { $service_name:
    ensure => $service_state,
    enable => $service,
  }
  # Clean up old cron-based configuration from previous module versions
  # Always remove cron.d file regardless of daily_restarts setting
  file { '/etc/cron.d/atop':
    ensure => absent,
  }
  # Remove old cron job from root's crontab (Puppet 7 only - cron type removed in Puppet 8)
  if versioncmp($facts['puppetversion'], '8.0.0') < 0 {
    cron { 'remove_atop':
      ensure => absent,
      user   => 'root',
    }
  }

  # Log cleanup via systemd timer (only when manage_retention is true)
  if ($manage_retention and $keepdays != undef) {
    file { '/etc/logrotate.d/atop':
      ensure => absent,
    }
    file { '/etc/systemd/system/atop-cleanup.service':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('atop/atop-cleanup.service.epp'),
    }
    file { '/etc/systemd/system/atop-cleanup.timer':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('atop/atop-cleanup.timer.epp'),
      notify  => Service['atop-cleanup.timer'],
    }
    service { 'atop-cleanup.timer':
      ensure  => running,
      enable  => true,
      require => File['/etc/systemd/system/atop-cleanup.timer'],
    }
  }

  # Daily restart via systemd timer (workaround for atop rotation issues)
  if ($daily_restarts) {
    file { '/etc/systemd/system/atop-restart.service':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('atop/atop-restart.service.epp'),
    }
    file { '/etc/systemd/system/atop-restart.timer':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp('atop/atop-restart.timer.epp'),
      notify  => Service['atop-restart.timer'],
    }
    service { 'atop-restart.timer':
      ensure  => running,
      enable  => true,
      require => File['/etc/systemd/system/atop-restart.timer'],
    }
  }
}

# vim: set et sw=2:
