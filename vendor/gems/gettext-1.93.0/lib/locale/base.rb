=begin
  locale/posix.rb 

  Copyright (C) 2002-2007  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: base.rb,v 1.1 2007/11/08 16:57:49 mutoh Exp $
=end


module Locale 
  # Locale::SystemBase module. This module overrides from other concrete modules. 
  # This is a low-level class. Application shouldn't use this directly.
  module SystemBase
    @@default_locale = Locale::Object.new("C", nil, "UTF-8")

    def default_locale  # :nodoc:
      @@default_locale
    end

    # Gets the charset of the locale.
    # * locale: Locale::Object
    # * Returns the charset of the locale
    def get_charset(locale)
      locale.charset || @@default_locale.charset
    end    

    # Gets the system locale using setlocale and nl_langinfo. 
    # * Returns the system locale (Locale::Object).
    def locale_from_env
      locale = nil
      # At least one environment valiables should be set on *nix system.
      [ENV["LC_ALL"], ENV["LC_MESSAGES"], ENV["LANG"]].each do |loc|
	if loc != nil and loc.size > 0
	  locale = Locale::Object.new(loc)
	  locale.charset ||= get_charset(locale)
	  break
	end
      end
      locale
    end

    # Gets the system locale.
    # * Returns the system locale (Locale::Object)   
    def system
      locale_from_env || default_locale
    end

    # Gets the charset of the locale.
    # * locale: Locale::Object
    # * Returns: the charset of the locale
    def charset
      # locale parameter is ignored now.
      system.charset
    end
  end
end

