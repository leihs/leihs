=begin
  gettext/erb.rb - GetText for ERB

  Copyright (C) 2005,2006  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: erb.rb,v 1.4 2006/12/06 16:39:58 mutoh Exp $
=end

require 'erb'
require 'gettext'

module GetText

  # This module provides basic functions to evaluate plural ERB files(.rhtml) in a TextDomain.
  # You need to implement a class which includes GetText::ErbContainer.
  #
  # See simple examples below:
  #
  #  require 'gettext/erb'
  #  class SimpleContainer
  #    include GetText::ErbContainer
  #     
  #    def initialize(domainname, domainpath = nil, locale = nil, charset = nil)
  #      bindtextdomain(domainname, domainpath, locale)
  #    end
  #  end
  #  
  #  container = SimpleContainer.new("helloerb1", "locale")
  #  puts container.eval_file("/your/erb/file.rhtml")
  #
  # This module is an example for template engines such as ERB. 
  # You can implement another implementation easily to read gettext/erb.rb.
  module ErbContainer
    include GetText

    # Evaluates ERB source(String) in the instance and returns the result HTML.
    #
    # * rhtml: an ERB source
    # * Returns: the Evaluated ERB result
    def eval_src(rhtml)
      erb = ERB.new(rhtml).src
      eval(erb, binding)
    end

    # Evaluates ERB file in the instance and returns the result HTML.
    #
    # * rhtml: an ERB file
    # * Returns: the Evaluated ERB result
    def eval_file(rhtmlpath)
      eval_src(IO.read(rhtmlpath))
    end
  end
end
