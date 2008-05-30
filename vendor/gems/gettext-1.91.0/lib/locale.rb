=begin
  locale.rb - Locale module

  Copyright (C) 2002-2007  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: locale.rb,v 1.2 2007/11/08 16:44:22 mutoh Exp $
=end

require 'locale/object'

if /cygwin|mingw|win32/ =~ RUBY_PLATFORM
  require 'locale/win32'
elsif /java/ =~ RUBY_PLATFORM
  require 'locale/jruby'
else
  require 'locale/posix'
end

# Locale module manages the locale informations of the application.
module Locale
  @@default = nil
  @@current = nil

  module_function
  # Sets the default locale (Locale::Object or String(such as ja_JP.eucJP)).
  #
  # * locale: the default locale
  # * Returns: self.
  def set_default(locale)
    if locale
      if locale.kind_of? Locale::Object
        @@default = locale
      else
        @@default = Locale::Object.new(locale)
      end
      @@default.charset ||= @@locale_system_module.charset
    else
      @@default = nil
    end
    self
  end
  # Same as Locale.set_default.
  #
  # * locale: the default locale (Locale::Object).
  # * Returns: locale.
  def default=(locale)
    set_default(locale)
    @@default
  end

  # Gets the system locale.
  # * Returns: the system locale (Locale::Object).
  def system
    @@locale_system_module.system
  end

  # Gets the default locale.
  #
  # If the default locale not set, this returns system locale.
  # * Returns: the default locale (Locale::Object).
  def default
    @@default ? @@default : system
  end

  # Gets the current locale (Locale::Object).
  #
  # If the current locale is not set, this returns default locale. 
  # * Returns: the current locale (Locale::Object).
  def current
    @@current = default unless @@current
    @@current
  end

  # Sets a locale as the current locale.
  #
  # This returns the current Locale::Object.
  # * lang: Locale::Object or locale name(String), or language name.
  # * country: the country code(String)
  # * charset: the charset(override the charset even if the locale name has charset).
  # * Returns: self
  #
  #    Locale.set_current("ja_JP.eucJP")
  #    Locale.set_current("ja", "JP")
  #    Locale.set_current("ja", "JP", "eucJP")
  #    Locale.set_current("ja", nil, "eucJP")
  #    Locale.set_current(Locale::Object.new("ja", "JP", "eucJP"))
  def set_current(lang, country = nil, charset = nil)
    if lang == nil
      @@current = nil
    else
      if lang.kind_of? Locale::Object
	@@current = lang
      else
	@@current = Locale::Object.new(lang, country, charset)
      end
      @@current.charset ||= @@locale_system_module.charset
    end
    self
  end

  # Sets a current locale. This is a single argument version of Locale.set_current.
  #
  # * lang: the Locale::Object
  # * Returns: the current locale (Locale::Object).
  #
  #    Locale.current = "ja_JP.eucJP"
  #    Locale.current = Locale::Object.new("ja", "JP", "eucJP")
  def current=(lang)
    set_current(lang)
    @@current
  end

  # call-seq:
  #   set(lang)
  #   set(lang, country = nil, charset = nil)
  #
  # * lang: language as String, or Locale::Object
  # * country: country as String or nil
  # * charset: charset as String or nil
  # * Returns: a Locale::Object.
  #
  # Sets a default locale. This function is an alias of Locale.set_default with
  # calling set_current(nil).
  #
  # *Notice*: Locale.set(lctype, locale) is deprecated.
  def set(lang, country = nil, charset = nil)
    set_current(nil)
    if lang.kind_of? String
      set_default(Locale::Object.new(lang, country, charset))
    elsif lang.kind_of? Locale::Object
      set_default(lang)
    else
      set_default(nil)
    end
    @@default
  end

  # call-seq:
  #   current
  #   get
  #
  # * Returns: the current locale (Locale::Object).
  #
  # *Notice*: lctype is deprecated. Use this with no parameter instead.
  def get
    @@current = default unless @@current
    @@current
  end

  # Same as charset. Gets the charset of the current locale.
  # * Returns: the charset of the current locale (String)
  def codeset
    current.charset
  end

  # Gets the charset of the current locale.
  # * Returns: the charset of the current locale (String)
  def charset
    codeset
  end 
  # Same as codeset. Returns the charset of the current locale. 
  # * Returns: the charset of the current locale (String)
  def current_charset
    codeset
  end

  # Clear default/current locale.
  # * Returns: self
  def clear
    set(nil)
    set_current(nil)
    self
  end

  # Gets the current system module. This is used for debugging.
  # * Returns: the system module.
  def system_module
    @@locale_system_module
  end
end
