require File.dirname(__FILE__) + '/../test_helper'

class KaufvorgangTest < Test::Unit::TestCase
  fixtures :kaufvorgangs

  def setup
    @kaufvorgang = Kaufvorgang.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Kaufvorgang,  @kaufvorgang
  end
end
