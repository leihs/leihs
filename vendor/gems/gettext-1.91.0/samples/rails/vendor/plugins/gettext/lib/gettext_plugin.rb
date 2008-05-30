# gettext_plugin.rb - a sample script for Ruby on Rails
#
# Copyright (C) 2005-2007 Masao Mutoh
#
# This file is distributed under the same license as Ruby-GetText-Package.

require 'gettext/rails'

module LangHelper
  include GetText::Rails

  bindtextdomain("gettext_plugin", :path => File.join(RAILS_ROOT, "vendor/plugins/gettext/locale"))

  def show_language
    langs = available_locales.sort
    ret = "<h4>" + _("Select locale") + "</h4>"
    langs.each_with_index do |lang, i|
      ret << link_to("[#{lang}]", :action => "cookie_locale", :id => lang)
      if ((i + 1) % 6 == 0)
	ret << "<br/>"
      end
    end
    ret
  end

  def cookie_locale
    cookies["lang"] = params["id"]
    set_locale params["id"]
    flash[:notice] = _('Cookie &quot;lang&quot; is set: %s') % params["id"]
    redirect_to :action => 'index'
  end
end
 
