require File.dirname(__FILE__) + '/../test_helper'

class ComputerdatenTest < Test::Unit::TestCase
  fixtures :computerdatens

  def setup
    @computerdaten = Computerdaten.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Computerdaten,  @computerdaten
  end
end
