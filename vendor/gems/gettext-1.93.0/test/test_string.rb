require 'test/unit'
require 'gettext'

class TestGetTextString < Test::Unit::TestCase
  def test_string_sprintf
    assert_equal("foo is a number", "%{msg} is a number" % {:msg => "foo"})
    assert_equal("bar is a number", "%s is a number" % ["bar"])
    assert_equal("bar is a number", "%s is a number" % "bar")
    assert_equal("1, test", "%{num}, %{record}" % {:num => 1, :record => "test"})
    assert_equal("test, 1", "%{record}, %{num}" % {:num => 1, :record => "test"})
    assert_equal("1, test", "%d, %s" % [1, "test"])
    assert_equal("test, 1", "%2$s, %1$d" % [1, "test"])
    assert_raise(ArgumentError) { "%-%" % [1] }
  end
end
