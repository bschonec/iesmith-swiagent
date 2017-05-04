# Author: Iain Smith <iain@iesmith.net>, 26/04/2017

# Compatability notes: Not compatible with Puppet 2.6.2 and earlier, due to
# style of inheritance from params class: 
# http://puppet-lint.com/checks/class_inherits_from_params_class/

class swiagent(
    $bindir       = $swiagent::params::bindir,
    $targethost   = $swiagent::params::targethost,
    $targetport   = $swiagent::params::targetport,
    $targetuser   = $swiagent::params::targetuser,
    $targetpw     = $swiagent::params::targetpw,
    $proxyhost    = $swiagent::params::proxyhost,
    $proxyport    = $swiagent::params::proxyport,
    $proxyuser    = $swiagent::params::proxyuser,
    $proxypw      = $swiagent::params::proxypw,
    $manageswipkg = $swiagent::params::manageswipkg,
    $managepkgs   = $swiagent::params::managepkgs,
    $nokogiripkg  = $swiagent::params::nokogiripkg,
    $testpath     = $swiagent::params::testpath,
    $catpath      = $swiagent::params::catpath
  ) inherits swiagent::params {

  # Ensure that Solarwinds agents and dependant packages are installed... 
  if $manageswipkg {
    package { 'swiagent': ensure => present }
  }
  if $managepkgs {
    package { $nokogiripkg: ensure => present }
  }

  # If no configuration file exists, create one and initialise the
  # securestring...
  exec { 'swiagent-init':
    onlyif  => "${testpath} ! -f ${bindir}/swiagent.cfg",
    command => "${bindir}/swiagent /logfile /initsecurestring",
  }

  # If Facter is able to detect the certificate fact, we're OK to proceed...
  if $::swiagent {
    if (has_key($::swiagent, 'certificate')
        and !has_key($::swiagent, 'target')) {

      # Build a temporary 'ini' file for swiagent configuration...
      file { 'swi-settings-init':
        path    => "${bindir}/swi.ini",
        mode    => '0600',
        owner   => 'root',
        group   => 'root',
        content => template('swiagent/swi.ini.erb')
      }

      # Register the installed agent with Solarwinds, and delete the settings
      # file (it may have...
      exec { 'swi-register':
        onlyif      => "${testpath} -f ${bindir}/swi.ini",
        command     => "${catpath} ${bindir}/swi.ini | ${bindir}/swiagent",
        subscribe   => File['swi-settings-init'],
        refreshonly => true
      }

      # Remove the settings file, as it may have passwords inside it...
      file { 'swi-settings-clean':
        ensure    => absent,
        path      => "${bindir}/swi.ini",
        subscribe => File['swi-register'],
      }
    }
  }

  # Ensure the service is running...
  service {'swiagentd':
    ensure => running,
    enable => true
  }
}
