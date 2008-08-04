require 'gettext'

class TestPGetText
  include GetText
  def initialize
    bindtextdomain("test_pgettext", "locale")
  end

  def test_1
    p_("AAA", "BBB")
  end
  
  def test_2
    pgettext("AAA", "BBB")
  end

  def test_3
    pgettext("AAA|BBB", "CCC")
  end
  
  def test_4
    p_("AAA", "CCC") #not found
  end

  def test_5
    p_("CCC", "BBB")
  end

  def test_6  # not pgettext.
    _("BBB")
  end

end
