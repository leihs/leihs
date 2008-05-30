require 'gettext'

include GetText
module TestLib3
  bindtextdomain("test2", "locale")

  class Test3
    def test3
      _("LANGUAGE")
    end
  end
end
