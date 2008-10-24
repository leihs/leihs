=begin
  locale/cgi.rb 

  Copyright (C) 2002-2007  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: cgi.rb,v 1.2 2007/11/08 16:44:22 mutoh Exp $
=end

require 'locale/base'

module Locale
  # Locale::System module for CGI.
  # This is a low-level class. Application shouldn't use this directly.
  module SystemCGI
    extend SystemBase

    @@default_locale = Locale::Object.new("en", nil, "UTF-8")
    @@cgi = nil

    module_function
    # Gets the default locale using setlocale and nl_langinfo. 
    # * Returns the system locale (Locale::Object).
    def system
      return @@default_locale unless @@cgi
      cgi_ = cgi
      if cgi_.has_key?("lang") and ret = cgi_["lang"] and ret.size > 0
      elsif ret = cgi_.cookies["lang"][0]
      elsif lang = cgi_.accept_language and lang.size > 0
	num = lang.index(/;|,/)
	ret = num ? lang[0, num] : lang
      else
	ret = @@default_locale.to_str
      end
 
      codesets = cgi_.accept_charset
      if codesets and codesets.size > 0
	num = codesets.index(',')
	codeset = num ? codesets[0, num] : codesets
	codeset = @@default_locale.charset if codeset == "*"
      else
	codeset = @@default_locale.charset
      end
      Locale::Object.new(ret, nil, codeset)
    end


    # Sets a CGI object.
    # * cgi_: CGI object
    # * Returns: self
    def set_cgi(cgi_)
      @@cgi = cgi_
      self
    end
    
    # Sets a CGI object.
    # * cgi_: CGI object
    # * Returns: cgi_ 
    def cgi=(cgi_)
      set_cgi(cgi_)
      cgi_
    end

    # Gets the CGI object. If it is nil, returns new CGI object.
    # * Returns: the CGI object
    def cgi
      @@cgi = CGI.new unless @@cgi
      @@cgi
    end

    # Gets the default Locale::Object. 
    # * Returns: the default locale
    def default_locale
      @@default_locale
    end
  end
  @@locale_system_module = SystemCGI

  module_function
  # Sets a CGI object.
  # * cgi_: CGI object
  # * Returns: self
  def set_cgi(cgi_)
    @@locale_system_module.set_cgi(cgi_)
    self
  end

  # Sets a CGI object.
  # * cgi_: CGI object
  # * Returns: cgi_ 
  def cgi=(cgi_)
    set_cgi(cgi_)
    cgi_
  end

  # Gets the CGI object. If it is nil, returns new CGI object.
  # * Returns: the CGI object
  def cgi
    @@locale_system_module.cgi
  end
end
