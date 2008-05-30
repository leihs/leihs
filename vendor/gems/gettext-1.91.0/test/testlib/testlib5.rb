class TestLib5
  include GetText
  def initialize
    bindtextdomain("test1", "locale")
    bindtextdomain("test2", "locale")
  end
  def test
    _("language")
  end
  def test2
    _("LANGUAGE")
  end
end

class TestLib6 < TestLib5
end

module TestLib7
  include GetText
  bindtextdomain("test1", "locale")

  module_function
  def test
    _("language")
  end

  class TestLib8
    include GetText
    def test
      _("language")
    end
    # Doesn't translate
    def test2
      _("LANGUAGE")
    end
  end

  class TestLib9
    include GetText
    def initialize
      bindtextdomain("test2", "locale")
    end
    def test
      _("language")
    end
    def test2
      _("LANGUAGE")
    end
  end
end

class TestLib10
  include GetText
  def initialize
    bindtextdomain("test1", "locale")
  end

  def test
    eval("_(\"language\")")
  end
end

class TestLib11
  include GetText
  bindtextdomain("test1", "locale")

  def test
    _("language")
  end
end
