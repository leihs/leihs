#!/usr/bin/ruby
# hellgtk.rb - sample for Ruby/GTK
#
# Copyright (C) 2001-2006 Masao Mutoh
# This file is distributed under the same license as Ruby-GetText-Package.

require 'gettext'
require 'gtk'

class LocalizedWindow < Gtk::Window
  include GetText

  bindtextdomain("hellogtk", "locale") 

  def initialize
    super
    signal_connect('delete-event') do
      Gtk.main_quit
    end

    add(Gtk::Label.new(_("hello, gtk world")))
  end
end

LocalizedWindow.new.show_all

Gtk.main
