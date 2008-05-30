require 'test/unit'

require 'gettext.rb'
include GetText

bindtextdomain("test1", "locale")
module Mod
  module_function
  def module_function
    _("language")
  end
end

class Cls
  def instance_method
    _("language")
  end
  def self.class_method
    _("language")
  end
end

def toplevel_method
  _("language")
end

class TestGetText < Test::Unit::TestCase
  include GetText

  def test_toplevel
    GetText.locale = "ja"
    assert_equal("japanese", toplevel_method)
    assert_equal("japanese", Mod.module_function)
    assert_equal("japanese", Cls.class_method)
    assert_equal("japanese", Cls.new.instance_method)

    GetText.remove_all_textdomains
    GetText.bindtextdomain("test1", "locale")
    assert_equal("japanese", toplevel_method)
    assert_equal("japanese", Mod.module_function)
    assert_equal("japanese", Cls.class_method)
    assert_equal("japanese", Cls.new.instance_method)
  end
end
