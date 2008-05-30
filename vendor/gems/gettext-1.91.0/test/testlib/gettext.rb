require 'gettext'
include GetText

class TestRubyParser
  bindtextdomain("test_rubyparser", "locale", "ja")

  def test_1
    _("aaa")
  end

  def test_2
    _("aaa\n")
  end

  def test_3
    _("bbb\nccc")
  end

  def test_4
     _("bbb
ccc
ddd
")
  end

  def test_5
    _("eee")
  end

  def test_6
    _("eee") + "foo" + _("fff")
  end

  def test_7
    _("ggg"\
      "hhh"\
      "iii")
  end

  def test_8
    _('a"b"c"')
  end

  def test_9
    _("d\"e\"f\"")
  end

  def test_10
    _("jjj") + 
    _("kkk")
  end

  def test_11
    _("lll" + "mmm")
  end

  def test_12
    puts _(msg), "ppp"  #Ignored
  end

  def test_13
    _("nnn\n" + 
      "ooo")
  end
  def test_14
    _("\#")
  end

  def test_15
    _('#')
  end

  def test_16
    _('\taaa')
  end

  def test_17
    ret = _(<<EOF
Here document1
Here document2
EOF
)
  end

  def test_18
    "<div>#{_('in_quote')}</div>"
  end
end

module ActionController
  class Base
  end
end
class ApplicationController < ActionController::Base
  "#{Time.now.strftime('%m/%d')}"
end
