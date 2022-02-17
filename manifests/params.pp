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
  $conf_file = $::osfamily ? {
    /Debian|Archlinux/ => '/etc/default/atop',
    'RedHat' => '/etc/sysconfig/atop',
    default  => fail('Unsupported Operating System.'),
  }
  $daily_restarts = $::osfamily ? {
    'RedHat' => true,
    default  => false
  }
  $conf_file_owner = 'root'
  $conf_file_group = 'root'
  $conf_file_mode = '0644'
  if ($facts.dig('systemd') == true) or ($facts.dig('systemd') == undef) {
      $conf_file_template = "atop/atop-Archlinux.erb"
  } else {
      $conf_file_template = $::osfamily ? {
        /Debian|RedHat|Archlinux/ => "atop/atop-${::osfamily}.erb",
        default  => fail('Unsupported Operating System.'),
      }
  }
}
# vim: set et sw=2:
