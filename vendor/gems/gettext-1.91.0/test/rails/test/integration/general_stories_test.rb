require "#{File.dirname(__FILE__)}/../test_helper"

RESULT_DIR = File.dirname(__FILE__) + "/../../test/result/"

class GeneralStoriesTest < ActionController::IntegrationTest
  fixtures :articles

  def assert_html(path)
    open(RESULT_DIR + path) {|io|
      data = io.read
      assert_equal data, @response.body
    }
  end
  def setup
    @first_id = articles(:first).id
  end

  def test_list
    get "/articles/list", nil, :accept_language => "ja"
    assert_html("ja/list.html")
    assert_response :success

    get "/articles/list", nil, :accept_language => "en"
    assert_html("en/list.html")
  end

  def test_show
    get "/articles/show/1", nil, :accept_language => "ja"
    assert_html("ja/show.html")
    assert_response :success
    assert_not_nil assigns(:article)
    assert assigns(:article).valid?

    get "/articles/show/1", nil, :accept_language => "en"
    assert_html("en/show.html")
  end

  def test_new
    get "/articles/new", nil, :accept_language => "ja"
    assert_html("ja/new.html")
    assert_response :success
    assert_not_nil assigns(:article)

    get "/articles/new", nil, :accept_language => "en"
    assert_html("en/new.html")
    assert_response :success
    assert_not_nil assigns(:article)
  end

  def test_create_error
    num_articles = Article.count
    post "/articles/create", {:article => {:title => "", :description => "", :lastupdate => Date.new(2007, 4, 1)}}, :accept_language => "ja"
    assert_html("ja/create_error.html")

    post "/articles/create", {:article => {:title => "", :description => "", :lastupdate => Date.new(2007, 4, 1)}}, :accept_language => "en"
    assert_html("en/create_error.html")
  end
end
