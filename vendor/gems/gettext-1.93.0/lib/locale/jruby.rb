=begin
  locale/jruby.rb

  Copyright (C) 2007 Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: jruby.rb,v 1.3 2008/03/21 06:28:10 mutoh Exp $
=end

require 'locale/base'
require 'java'

module Locale
  # Locale::SystemJRuby module for JRuby
  # This is a low-level class. Application shouldn't use this directly.
  module SystemJRuby
    extend SystemBase

    if java.lang.System.getProperties['os.name'].downcase =~ /windows/
      require 'locale/win32_table'

      extend ::Locale::SystemWin32Table
    end

    module_function
    def default_locale  #:nodoc:
      locale = java.util.Locale.getDefault
      charset = java.nio.charset.Charset.defaultCharset.name
      Locale::Object.new(locale.to_s, nil, charset)
    end
  end
  @@locale_system_module = SystemJRuby
end

