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


################################################
# TODO 2901 temporary fixing locale_rails issue, remove this when locale_rails > 2.0.5
# source: http://github.com/mutoh/locale_rails/blob/2bad60660127683c259fe/lib/locale_rails/i18n.rb

=begin
  locale_rails/lib/i18n.rb - Ruby/Locale for "Ruby on Rails"

  Copyright (C) 2008,2009  Masao Mutoh

  You may redistribute it and/or modify it under the same
  license terms as Ruby or LGPL.

=end

module I18n
  module_function

  # Gets the supported locales.
  def supported_locales 
    ::Locale.app_language_tags
  end

  # Sets the supported locales.
  #  I18n.set_supported_locales("ja-JP", "ko-KR", ...)
  def set_supported_locales(*tags)
    ::Locale.set_app_language_tags(*tags)
  end

  # Sets the supported locales as an Array.
  #  I18n.supported_locales = ["ja-JP", "ko-KR", ...]
  def supported_locales=(tags)
    ::Locale.set_app_language_tags(*tags)
  end

  # Sets the ::Locale.
  #  I18n.locale = "ja-JP"
  def locale=(tag)
    ::Locale.clear
    tag = Locale::Tag::Rfc.parse(tag.to_s) if tag.kind_of? Symbol
    ::Locale.current = tag
    Thread.current[:locale] = ::Locale.candidates(:type => :rfc)[0]
  end

  # Sets the default ::Locale.
  #  I18n.default_locale = "ja"
  def default_locale=(tag)
    tag = Locale::Tag::Rfc.parse(tag.to_s) if tag.kind_of? Symbol
    ::Locale.default = tag
    @@default_locale = tag
  end
  
  class << self

    # MissingTranslationData is overrided to fallback messages in candidate locales.
    def locale_rails_exception_handler(exception, locale, key, options) #:nodoc:
      ret = nil
      ::Locale.candidates(:type => :rfc).each do |loc|
        begin
          ret = backend.translate(loc, key, options)
          break
        rescue I18n::MissingTranslationData 
          ret = I18n.default_exception_handler(exception, locale, key, options)
        end
      end
      ret
    end
    I18n.exception_handler = :locale_rails_exception_handler
  end

end

