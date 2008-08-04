require 'gettext'

class TestLib6
  include GetText
  def initialize
    bindtextdomain("test6", "locale")
  end
  def test
    _("language")
  end

  def test_formatted_string
    _("one is %d.") % 1
  end

  def setlocale(lang)
    set_locale(lang, true)
  end
end
