#!/usr/bin/ruby
# hellgtk2.rb - sample for Ruby/GTK2
#
# Copyright (C) 2001-2006 Masao Mutoh
# This file is distributed under the same license as Ruby-GetText-Package.

require 'gettext'
require 'gtk2'

class LocalizedWindow < Gtk::Window
  include GetText

  bindtextdomain("hellogtk", "locale", nil, "utf-8") 

  def initialize
    super
    signal_connect('delete-event') do
      Gtk.main_quit
    end

    add(Gtk::Label.new(_("hello, gtk world")))
  end
end

Gtk.init
LocalizedWindow.new.show_all
Gtk.main
