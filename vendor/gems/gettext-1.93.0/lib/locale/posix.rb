=begin
  locale/posix.rb 

  Copyright (C) 2002-2007  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: posix.rb,v 1.4 2008/09/15 16:32:39 mutoh Exp $
=end

require 'locale/base'

module Locale 
  # Locale::SystemPosix module for Posix OS (Unix)
  # This is a low-level class. Application shouldn't use this directly.
  module SystemPosix
    extend SystemBase

    module_function
    # Gets the charset of the locale.
    # * locale: Locale::Object
    # * Returns the charset of the locale
    def get_charset(locale)
      charset = `LANG=#{locale.to_str};locale charmap`.strip
      unless $? && $?.success?
        charset = "UTF-8"
      end
      charset
    end  
  end

  @@locale_system_module = SystemPosix

end

