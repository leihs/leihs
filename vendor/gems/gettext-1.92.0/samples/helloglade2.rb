#!/usr/bin/env ruby
# helloglade2.rb - sample for Ruby/Libglade2
#
# Copyright (C) 2004 Masao Mutoh
# This file is distributed under the same license as Ruby-GetText-Package.

require 'libglade2'

class HelloLibglade2
  def initialize(path, appname)
    @glade = GladeXML.new(path, nil, appname, "locale") {|handler| method(handler)}
  end
  def on_quit
    puts "Hello world"
    Gtk.main_quit
  end
end

if __FILE__ == $0
  APPNAME = "helloglade2"
  Gnome::Program.new(APPNAME, "1.0")
  HelloLibglade2.new("helloglade2.glade", APPNAME)
  Gtk.main
end
