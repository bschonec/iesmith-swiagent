#!/usr/bin/ruby

# Custom fact script for Facter, intended to export swiagent configuration
# variables to Puppet...

require 'rubygems'
require 'facter'
require 'rexml/document'
include REXML

cfgfile = '/opt/SolarWinds/Agent/bin/swiagent.cfg'

if File.exist?(cfgfile)
  facts = {}

  begin
    xml = File.open(cfgfile) { |f| Document.new(f) }

    XPath.each(xml, '//certificate/*|//executer/*|//target/*|//httpproxy/*') do |node|
      parent = node.parent.name
      facts[parent] ||= {}
      facts[parent][node.name] = node.text
    end

  rescue Exception => ex
    Facter.warn("Unable to parse #{cfgfile}: #{ex.message}")
  end

  Facter.add(:swiagent) do
    setcode { facts }
  end
end
