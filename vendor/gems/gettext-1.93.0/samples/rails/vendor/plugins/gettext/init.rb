# init.rb - a sample script for Ruby on Rails
#
# Copyright (C) 2005-2008 Masao Mutoh
#
# This file is distributed under the same license as Ruby-GetText-Package.

require 'gettext_plugin'

ActionController::Base.class_eval do
  include LangHelper
  helper LangHelper
  before_filter{ |controller|
    if controller.params["action"] == "cookie_locale"
      controller.cookie_locale
    end
  }
end

ActionView::Base.class_eval do
  include LangHelper
end
