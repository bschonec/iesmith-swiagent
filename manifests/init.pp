# Author: Iain Smith <iain@iesmith.net>, 26/04/2017

# Compatability notes: Not compatible with Puppet 2.6.2 and earlier, due to
# style of inheritance from params class: 
# http://puppet-lint.com/checks/class_inherits_from_params_class/

class swiagent (
  String $target,
  String $proxy_password,
  String $ca_content,
  String $provisioning_content,

  $bindir = $swiagent::params::bindir,
  $testpath = $swiagent::params::testpath,

  Boolean $installcert            = true,
  Boolean $run_provision = true,
  String $relative_path = 'ini',
  Boolean $ca_pwd = true,
  Integer $port = 17778,
  Variant[Array, Stdlib::IP::Address::V4, Stdlib::IP::Address::V4::CIDR] $ipaddress = '127.0.0.1',
  String $targetdeviceid = '00000000-0000-0000-0000-000000000000',
  Boolean $is_active = true,
  Integer $server_http_port = 17790,
  Enum['enabled','disabled']       $proxy_access_type              = 'disabled',
  String $ca_cert = 'ca_cert',
  String $cert = 'provisioning.pfx'

) inherits swiagent::params {

  $ini_file = 'swi.ini'

  # Ensure that Solarwinds agents and dependant packages are installed... 
  package { 'swiagent':
    ensure => present,
  }

  # Build the 'permanent' file for swiagent configuration...
  file { 'swi-settings-init':
    path    => "${bindir}/${ini_file}",
    mode    => '0600',
    owner   => 'swiagent',
    group   => 'swiagent',
    content => template("swiagent/${ini_file}.erb"),
    require => Package['swiagent'],
    notify  => Exec['configure'],
  }

  # create the ca_cert file
  $ca_cert_file = "${bindir}/${ca_cert}"
  file {$ca_cert_file:
    mode    => '0600',
    owner   => 'swiagent',
    group   => 'swiagent',
    source  => $ca_content,
    notify  => Exec['configure'],
  }

  # create the provisioning.pfx file.
  #
  $provisioning_file = "${bindir}/${cert}"
  file {$provisioning_file:
    mode    => '0600',
    owner   => 'swiagent',
    group   => 'swiagent',
    source  => $provisioning_content,
    notify  => Exec['configure'],
  }

  # Configure via the shell script
  exec { 'configure':
    cwd     => $bindir,
    onlyif  => "${testpath} -f ${ini_file}",
    command => "${bindir}/swiagentaid.sh init /installcert /s iniFile=${bindir}/${ini_file} ca_cert=${ca_cert_file} cert=${provisioning_file}",
    require => [File['swi-settings-init'], File[$ca_cert_file], File[$provisioning_file], ],
    refreshonly => true,
    notify => Service['swiagentd'],
  }

  # Ensure the service is running...
  service { 'swiagentd':
    ensure  => running,
    enable  => true,
    require => File['swi-settings-init'],
  }
}
