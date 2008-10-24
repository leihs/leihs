#!/usr/bin/env ruby
=begin
  helloerb2.cgi - Sample script for CGI/ERB

  Set locale/charset automaticaly.
  (from HTTP_ACCEPT_LANGUAGE, HTTP_ACCEPT_CHARSET sended by web browser).

  Recommanded to set UTF-8 forcely because some web browser
  doesn't send HTTP_ACCEPT_CHARSET correctly.(See helloerb.cgi)

  Copyright (C) 2005  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby.
=end

begin
  require 'rubygems'
rescue LoadError
end

require 'gettext/cgi'
require 'gettext/erb'

class SimpleContainer2
  include GetText::ErbContainer

  def initialize(domainname, domainpath)
    bindtextdomain(domainname, :path => domainpath)
    @domainname = domainname
  end

  def description
    _("Sample script for CGI/ERB (Auto-Detect charset).")
  end

  def to_html(path)
    eval_file(path)
  end
end

cgi = CGI.new
GetText.set_cgi(cgi)

print "Content-type:text/html; charset=#{Locale.get.charset}\n\n"

con = SimpleContainer2.new("helloerb2", "locale")

print con.to_html("helloerb.rhtml")
