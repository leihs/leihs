require 'testlib/testlib1'

class TestLib4
  include GetText
  def initialize
    textdomain("test1")
  end
  def test
    _("language")
  end
end
