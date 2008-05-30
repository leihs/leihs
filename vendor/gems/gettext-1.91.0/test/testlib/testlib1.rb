require 'gettext'

class TestLib1
  include GetText
  def initialize
    bindtextdomain("test1", "locale")
  end
  def test
    _("language")
  end

  def test_formatted_string
    _("one is %d.") % 1
  end
end
