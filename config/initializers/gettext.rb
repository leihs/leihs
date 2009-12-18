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