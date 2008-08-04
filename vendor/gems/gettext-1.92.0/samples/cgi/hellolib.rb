#!/usr/bin/ruby
# hellolib.rb
#
# Copyright (C) 2005  Masao Mutoh
#
# This file is distributed under the same 
# license as Ruby-GetText-Package.
#
# $Id: hellolib.rb,v 1.1.1.1 2005/08/13 02:38:08 mutoh Exp $
#

require 'gettext'

include GetText

class HelloLib
  bindtextdomain("hellolib", "locale")
  def hello
    _("This message is from hellolib.")
  end
end
