#!/usr/bin/ruby

# Custom fact script for Facter, intended to export swiagent configuration
# variables to Puppet...

cfgfile = '/opt/SolarWinds/Agent/bin/swiagent.cfg'

if File.exist?(cfgfile)
  require 'rubygems'
  require 'facter'


  # Parse XML file, and step over the configuration elements...
  facts = Hash.new
  begin
    xml = File.open(cfgfile) { |f| Document.new(f) }
    XPath.each(xml, '//certificate/*|//executer/*|//target/*|//httpproxy/*') do |node|
      parent = node.parent.name
      facts[parent] ||= {}
      facts[parent][node.name] = node.text
    end

  rescue Exception => ex
    Puppet.warning "Unable to parse " + cfgfile + ": " + ex.message
  end

  # Export discovered facts into Facter...
  Facter.add(:swiagent) do
    setcode do
      facts
    end
  end
end
