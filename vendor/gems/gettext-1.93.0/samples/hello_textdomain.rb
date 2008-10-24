#!/usr/bin/ruby
# hello_textdomain.rb - sample for GetText.textdomain.
#
# Copyright (C) 2005, 2006 Masao Mutoh
# This file is distributed under the same license as Ruby-GetText-Package.

# hello.rb calles hello textdomain first.
require 'hello'

module HelloTextDomain
  include GetText

  textdomain("hello")

  module_function 
  def hello
    puts _("Hello World\n")
  end
end

HelloTextDomain.hello
