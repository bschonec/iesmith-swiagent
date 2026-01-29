# Author: Iain Smith <iain@iesmith.net>, 26/04/2017

class swiagent::params {
  # Generic default settings...
  $bindir = hiera('swiagent::bindir', '/opt/SolarWinds/Agent/bin')

  case $facts['os']['family'] {
    'RedHat': {
      # Assign package names...
      $managepkgs = true

      # Assign basic binary paths...
      $testpath = '/usr/bin/test'
    }
    default: {
      # TODO: We'll need to draw attention to default handing here later on...
      $managepkgs = false
    }
  }
}
