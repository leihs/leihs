require File.dirname(__FILE__) + '/../test_helper'
class ArticleTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def test_truth
    assert_kind_of Article,  Article.find(1)
  end
end
