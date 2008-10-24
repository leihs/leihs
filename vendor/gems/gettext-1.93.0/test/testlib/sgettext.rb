require 'gettext'

class TestSGetText
  include GetText
  def initialize
    bindtextdomain("test_sgettext", "locale")
  end

  def test_1
    s_("AAA|BBB")
  end
  
  def test_2
    sgettext("AAA|BBB")
  end
  
  def test_3
    s_("AAA") #not found
  end

  def test_4
    s_("AAA|CCC") #not found
  end

  def test_5
    s_("AAA|BBB|CCC") #not found
  end

  def test_6
    s_("AAA$BBB", "$") #not found
  end

  def test_7
    s_("AAA$B|BB", "$") #not found
  end

  def test_8
    s_("AAA$B|CC", "$")
  end

  def test_9
    s_("AAA|CCC|BBB") #not found
  end

  def setlocale(locale)
    __setlocale(locale)
  end
end
