require 'test/unit'

require 'gettext'
require 'testlib/testlib5.rb'

class TestGetTextMulti < Test::Unit::TestCase
  def setup
    GetText.locale = nil
  end

  def test_two_domains_in_a_class
    testlib = TestLib5.new
    assert_equal("japanese", testlib.test)
    assert_equal("JAPANESE", testlib.test2)
  end

  def test_inheritance
    # inheritance. only parent has a textdomain and it's methods
    testlib = TestLib6.new
    assert_equal("japanese", testlib.test)
    assert_equal("JAPANESE", testlib.test2)
  end

  def test_module_and_sub_modules
    # module
    assert_equal("japanese", TestLib7.test)

    # sub-module. only an included module has a textdomain and it's methods
    testlib2 = TestLib7::TestLib8.new
    assert_equal("japanese", testlib2.test)
    assert_equal("LANGUAGE", testlib2.test2)  # No influence
  end

  def test_supply_by_parent_module_domain
    testlib3 = TestLib7::TestLib9.new
    assert_equal("japanese", testlib3.test)
    assert_equal("JAPANESE", testlib3.test2)
  end

  def test_eval
    testlib = TestLib10.new
    assert_equal("japanese", testlib.test)
  end

  def test_as_class_methods
    testlib = TestLib11.new
    assert_equal("japanese", testlib.test)
  end
end
