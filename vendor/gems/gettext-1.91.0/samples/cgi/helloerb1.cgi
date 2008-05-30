#!/usr/bin/env ruby
=begin
  helloerb1.cgi - Sample script for CGI/ERB

  Set UTF-8 forcely as output charset.

  Recommanded to set UTF-8 forcely because some web browser
  doesn't send HTTP_ACCEPT_CHARSET correctly.

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

class SimpleContainer1
  include GetText::ErbContainer

  def initialize(domainname, domainpath, cgi)
    set_cgi(cgi)
    bindtextdomain(domainname, :path => domainpath)
    @domainname = domainname
  end

  def description
    _("Sample script for CGI/ERB (UTF-8).")
  end

  def to_html(path)
    eval_file(path)
  end
end


GetText.output_charset = "UTF-8"

print "Content-type:text/html; charset=UTF-8\n\n"

cgi = CGI.new

con = SimpleContainer1.new("helloerb1", "locale", cgi)

if GetText.cgi["other"] == "true"
  print con.to_html("other.rhtml")
else
  print con.to_html("helloerb.rhtml")
end
