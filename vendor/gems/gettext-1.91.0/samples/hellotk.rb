#!/usr/bin/ruby
# hellotk.rb - sample for Ruby/TK
#
# Copyright (C) 2004 Masao Mutoh
# This file is distributed under the same license as Ruby-GetText-Package.

require 'gettext'
require 'tk'

include GetText
bindtextdomain("hellotk", "locale")

TkLabel.new {
  text _("hello, tk world")
  pack
}

Tk.mainloop
