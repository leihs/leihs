require File.dirname(__FILE__) + '/../test_helper'

class AttributTest < Test::Unit::TestCase
  fixtures :attributs

  def setup
    @attribut = Attribut.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Attribut,  @attribut
  end
end
