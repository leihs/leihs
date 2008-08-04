=begin
  gettext/cgi.rb - GetText for CGI

  Copyright (C) 2005  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.

  $Id: cgi.rb,v 1.7 2007/10/29 15:32:39 mutoh Exp $
=end

require 'cgi'
require 'gettext'
require 'locale/cgi'

module GetText
  module_function

  # Sets a CGI object.
  # * cgi_: CGI object
  # * Returns: self
  def set_cgi(cgi_)
    Locale.set_cgi(cgi_)
  end

  # Same as GetText.set_cgi.
  # * cgi_: CGI object
  # * Returns: cgi_
  def cgi=(cgi_)
    set_cgi(cgi_)
    cgi_
  end

  # Gets the CGI object. If it is nil, returns new CGI object.
  # * Returns: the CGI object
  def cgi
    Locale.cgi
  end
end
