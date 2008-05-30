$:.unshift(File.dirname(__FILE__) + '../../lib')

require 'test/unit'
require 'rubygems'
if Kernel.respond_to? :gem
  gem 'rails'
else
  require_gem 'rails'
end
require 'initializer'
begin
  require 'rails_info'
rescue Exception
  module Rails
    module Info
      module_function
      def property(name, &block)
	
      end
    end
  end
end
require 'gettext/rails'
require 'stringio'

class TestRails < Test::Unit::TestCase
  def setup_cgi(str)
    $stdin = StringIO.new(str)
    ENV["REQUEST_URI"] = "http://localhost:3000/"
    cgi = CGI.new
    Locale.cgi = cgi
  end

  def test_bindtextdomain
    #query string
    Locale.default = Locale::Object.new("ja_JP.UTF-8")
    GetText.locale = "fr"
    GetText.bindtextdomain("test1", "locale")
    assert_equal("french", GetText._("language"))
    setup_cgi("lang=ja_JP")
    ENV["HTTP_ACCEPT_LANGUAGE"] = "ja,en-us;q=0.7,en;q=0.3"
    GetText.bindtextdomain("test1", "locale")
    assert_equal("french", GetText._("language"))
  end
end
