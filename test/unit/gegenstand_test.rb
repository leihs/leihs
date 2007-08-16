require File.dirname(__FILE__) + '/../test_helper'

class GegenstandTest < Test::Unit::TestCase
  fixtures :gegenstands

  def setup
    @gegenstand = Gegenstand.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Gegenstand,  @gegenstand
  end
end
