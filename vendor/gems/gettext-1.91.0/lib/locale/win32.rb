=begin
  locale/win32.rb

  Copyright (C) 2002-2008  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: win32.rb,v 1.5 2008/03/21 06:28:10 mutoh Exp $
=end

require 'locale/base'
require 'locale/win32_table'
require 'dl/win32'

module Locale
  # Locale::SystemWin32 module for win32.
  # This is a low-level class. Application shouldn't use this directly.
  module SystemWin32
    extend SystemBase
    include SystemWin32Table

    @@default_locale = Locale::Object.new("en", nil, "CP1252")
    @@win32 = Win32API.new("kernel32.dll", "GetUserDefaultLangID", nil, "i")

    module_function

    # Gets the Win32 charset of the locale. 
    # * locale: Locale::Object
    # * Returns the charset of the locale
    def get_charset(locale)
      loc = LocaleTable.find{|v| v[1] == locale.to_win}
      loc = LocaleTable.find{|v| v[1] =~ /^#{locale.language}-/} unless loc
      loc ? loc[2] : "CP1252"
    end

    def default_locale  #:nodoc:
      lang = LocaleTable.assoc(@@win32.call)
      if lang
        ret = Locale::Object.new(lang[1], nil, lang[2])
      else
        ret = @@default_locale
      end
      ret
    end
  end
  @@locale_system_module = SystemWin32
end

