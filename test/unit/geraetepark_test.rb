require File.dirname(__FILE__) + '/../test_helper'

class GeraeteparkTest < Test::Unit::TestCase
  fixtures :geraeteparks

  def setup
    @geraetepark = Geraetepark.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Geraetepark,  @geraetepark
  end
end
