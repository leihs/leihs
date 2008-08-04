=begin
  parser/erb.rb - parser for ERB

  Copyright (C) 2005  Masao Mutoh
 
  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: erb.rb,v 1.5 2007/08/01 01:39:14 mutoh Exp $
=end

require 'erb'
require 'gettext/parser/ruby.rb'

module GetText
  module ErbParser
    @config = {
      :extnames => ['.rhtml', '.erb']
    }

    module_function
    # Sets some preferences to parse ERB files.
    # * config: a Hash of the config. It can takes some values below:
    #   * :extnames: An Array of target files extension. Default is [".rhtml"].
    def init(config)
      config.each{|k, v|
	@config[k] = v
      }
    end

    def parse(file, targets = []) # :nodoc:
      erb = ERB.new(IO.readlines(file).join).src.split(/$/)
      RubyParser.parse_lines(file, erb, targets)
    end

    def target?(file) # :nodoc:
      @config[:extnames].each do |v|
	return true if File.extname(file) == v
      end
      false
    end
  end
end

if __FILE__ == $0
  # ex) ruby glade.rhtml foo.rhtml  bar.rhtml
  ARGV.each do |file|
    p GetText::ErbParser.parse(file)
  end
end
