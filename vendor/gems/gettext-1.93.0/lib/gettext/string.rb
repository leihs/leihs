#! /usr/bin/ruby
=begin
  string.rb - Extension for String.

  Copyright (C) 2005,2006 Masao Mutoh
 
  You may redistribute it and/or modify it under the same
  license terms as Ruby.
=end

# Extension for String class.
#
# String#% method which accept "named argument". The translator can know 
# the meaning of the msgids using "named argument" instead of %s/%d style.
class String
  alias :_old_format_m :% # :nodoc:
    
  # call-seq:
  #  %(arg)
  #  %(hash)
  #
  # Format - Uses str as a format specification, and returns the result of applying it to arg. 
  # If the format specification contains more than one substitution, then arg must be 
  # an Array containing the values to be substituted. See Kernel::sprintf for details of the 
  # format string. This is the default behavior of the String class.
  # * arg: an Array or other class except Hash.
  # * Returns: formatted String
  #
  #  (e.g.) "%s, %s" % ["Masao", "Mutoh"]
  #
  # Also you can use a Hash as the "named argument". This is recommanded way for Ruby-GetText
  # because the translators can understand the meanings of the msgids easily.
  # * hash: {:key1 => value1, :key2 => value2, ... }
  # * Returns: formatted String
  #
  #  (e.g.) "%{firstname}, %{familyname}" % {:firstname => "Masao", :familyname => "Mutoh"}
  def %(args)
    if args.kind_of?(Hash)
      ret = dup
      args.each {|key, value|
        ret.gsub!(/\%\{#{key}\}/, value.to_s)
      }
      ret
    else
      ret = gsub(/%\{/, '%%{')
      begin
	ret._old_format_m(args)
      rescue ArgumentError => e
        if $DEBUG
  	   $stderr.puts "  The string:#{ret}"
	   $stderr.puts "  args:#{args.inspect}"
           puts e.backtrace
	else	
	  raise ArgumentError, e.message
	end
      end
    end
  end
end
