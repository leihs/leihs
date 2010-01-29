##  http://zargony.com/2008/02/12/edge-rails-and-gettext-undefined-method-file_exists-nomethoderror
#  module ActionView
#    class Base
#      delegate :file_exists?, :to => :finder unless respond_to?(:file_exists?)
#    end
#  end
#
#  # We want gettext functionality.
#  require 'gettext/rails'

################################################
  include GetText
#  GetText.locale = "de_CH"
#  set_locale "de_CH"
#  bindtextdomain('leihs')


# TODO 2901 make I18n and GetText working together  
module ActionView
  module Helpers
    module DateHelper
      def date_select(object_name, method, options = {}, html_options = {})
        #sellittf#
        default_options = { :use_month_names => Date::MONTHNAMES }
        options = default_options.merge(options)
        
        InstanceTag.new(object_name, method, self, options.delete(:object)).to_date_select_tag(options, html_options)
      end
    end
  end
end