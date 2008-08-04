require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles

  # Replace this with your real tests.
  def test_first
    article = articles(:first)
    assert_equal 1, article.id
    assert_equal "内容1", article.description
    assert_equal Date.parse("2007-01-01"), article.lastupdate

    article = articles(:second)
    assert_equal 2, article.id
    assert_equal "内容2", article.description
    assert_equal Date.parse("2007-01-02"), article.lastupdate
  end
end
