# == Class atop::params
# This class is meant to be called from atop
# It set variable according to platform
class atop::params {
  $package_name = 'atop'
  $service_name = 'atop'
  $service = false
  $interval = 600
  $logpath = '/var/log/atop'
  $keepdays = undef
  $manage_retention = false
  $daily_restarts = false
  $osfamily = $facts['os']['family']
  $conf_file = $osfamily ? {
    /Debian|Archlinux/ => '/etc/default/atop',
    'RedHat'           => '/etc/sysconfig/atop',
    default            => fail('Unsupported Operating System.'),
  }
  $conf_file_owner = 'root'
  $conf_file_group = 'root'
  $conf_file_mode = '0644'
  $conf_file_template = 'atop/atop.erb'
}
# vim: set et sw=2:
