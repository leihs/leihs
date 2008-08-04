require 'testlib/testlib1.rb'

class TestLib2 < TestLib1
  def initialize
    super
    bindtextdomain("test2", "locale")
  end
  def test2
    _("LANGUAGE")
  end
end
