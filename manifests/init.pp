# Author::    Liam Bennett (mailto:liamjbennett@gmail.com)
# Copyright:: Copyright (c) 2014 Liam Bennett
# License::   MIT

# == Class: windows_firewall
#
# Module to manage the windows firewall and it's configured exceptions
#
# === Requirements/Dependencies
#
# Currently reequires the puppetlabs/stdlib module on the Puppet Forge in
# order to validate much of the the provided configuration.
#
# === Parameters
#
# [*ensure*]
# Control the state of the windows firewall application
#
# === Examples
#
# To ensure that windows_firwall is running:
#
#   include ::windows_firewall
#
class windows_firewall (
  Enum['stopped', 'running'] $ensure = 'running',
  Boolean $enable = true,
) {

  case $::operatingsystemversion {
    /Windows Server 2003/,/Windows Server 2003 R2/,/Windows XP/: {
      $firewall_name = 'SharedAccess'
    }
    default: {
      $firewall_name = 'MpsSvc'
    }
  }

  if $ensure == 'running' {
    $enabled_data = '1'
  } else {
    $enabled_data = '0'
  }

  if $enable == false  {
    notice ( "enable is ${enable}, overriding ensure to stopped" )
    $_ensure = 'stopped'
  } else {
    $_ensure = 'running'
  }

  service { 'windows_firewall':
    ensure => $_ensure,
    name   => $firewall_name,
    enable => $enable,
  }

  registry_value { 'EnableFirewallDomainProfile':
    ensure => 'present',
    path   => '32:HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile\EnableFirewall',
    type   => 'dword',
    data   => $enabled_data,
  }

  registry_value { 'EnableFirewallPublicProfile':
    ensure => 'present',
    path   => '32:HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile\EnableFirewall',
    type   => 'dword',
    data   => $enabled_data,
  }

  registry_value { 'EnableFirewallStandardProfile':
    ensure => 'present',
    path   => '32:HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile\EnableFirewall',
    type   => 'dword',
    data   => $enabled_data,
  }
}
