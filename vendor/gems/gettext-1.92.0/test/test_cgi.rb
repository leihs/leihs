require 'test/unit'
require 'gettext/cgi'

class CGI
  module QueryExtension
    # Override this method to avoid to put warning messages.
    module_function
    def readlines=(str)
      @@lines = [str]
    end
    def readlines
      @@lines
    end
    def read_from_cmdline
      require "shellwords"
      string = readlines.join(' ').gsub(/\n/n, '').gsub(/\\=/n, '%3D').gsub(/\\&/n, '%26')
      
      words = Shellwords.shellwords(string)
      
      if words.find{|x| /=/n.match(x) }
        words.join('&')
      else
        words.join('+')
      end
    end
    private :read_from_cmdline
  end
end

class TestGetTextCGI < Test::Unit::TestCase
  def setup_cgi(str)
    CGI::QueryExtension.readlines = str
    cgi = CGI.new
    Locale.cgi = cgi
  end

  def test_system
    #query string
    setup_cgi("lang=ja_JP")
    assert_equal("ja_JP", Locale.system.to_str)
    setup_cgi("lang=ja-jp")
    assert_equal("ja_JP", Locale.system.to_str)
    assert_equal("ja-JP", Locale.system.to_iso3066)
    setup_cgi("lang=ja-jp")
    assert_equal("ja_JP", Locale.system.to_str)
    assert_equal("ja-JP", Locale.system.to_iso3066)
    setup_cgi("")
    ENV["HTTP_ACCEPT_LANGUAGE"] = ""
    ENV["HTTP_ACCEPT_CHARSET"] = ""
    assert_equal("en", Locale.system.to_str)
    assert_equal("en", Locale.system.to_iso3066)

    #cockie
    setup_cgi("Set-Cookie: lang=en-us")
    assert_equal("en_US", Locale.system.to_str)

    #accept language
    setup_cgi("")
    ENV["HTTP_ACCEPT_LANGUAGE"] = "ja,en-us;q=0.7,en;q=0.3"
    assert_equal("ja", Locale.system.to_str)
    assert_equal("ja", Locale.system.to_iso3066)
    ENV["HTTP_ACCEPT_LANGUAGE"] = "en-us,ja;q=0.7,en;q=0.3"
    assert_equal("en_US", Locale.system.to_str)
    assert_equal("en-US", Locale.system.to_iso3066)
    ENV["HTTP_ACCEPT_LANGUAGE"] = "en"
    assert_equal("en", Locale.system.to_str)
    assert_equal("en", Locale.system.to_iso3066)

    #accept charset
    ENV["HTTP_ACCEPT_CHARSET"] = "Shift_JIS"
    assert_equal("Shift_JIS", Locale.system.charset)
    ENV["HTTP_ACCEPT_CHARSET"] = "EUC-JP,*,utf-8"
    assert_equal("EUC-JP", Locale.system.charset)
    ENV["HTTP_ACCEPT_CHARSET"] = "*"
    assert_equal("UTF-8", Locale.system.charset)
    ENV["HTTP_ACCEPT_CHARSET"] = ""
    assert_equal("UTF-8", Locale.system.charset)
  end

  def test_default
    Locale.set_default(nil)
    Locale.set_default(Locale::Object.new("ja_JP", nil, "EUC-JP"))
    setup_cgi("")
    ENV["HTTP_ACCEPT_LANGUAGE"] = ""
    ENV["HTTP_ACCEPT_CHARSET"] = ""
    assert_equal("ja_JP", Locale.default.to_str)
    assert_equal("EUC-JP", Locale.default.charset)
    Locale.set_default(nil)
  end

end
