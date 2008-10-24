require File.dirname(__FILE__) + '/../test_helper'
require 'articles_controller'

unless defined? RESULT_DIR
  RESULT_DIR = File.dirname(__FILE__) + "/../../test/result/"
end

# Re-raise errors caught by the controller.
class ArticlesController; def rescue_action(e) raise e end; end
GetText
class ArticlesControllerTest < Test::Unit::TestCase
  fixtures :articles

  def setup
    @controller = ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = articles(:first).id
  end

  def save_html(path)
    open(RESULT_DIR + path, "w"){|io| io.write @response.body}
  end

  def assert_html(path)
    unless File.exist?(RESULT_DIR + path)
      save_html(path)
    end   
    ary = IO.readlines(RESULT_DIR + path)
    i = 0
    @response.body.each_line{|line|
      assert_equal ary[i], line
      i += 1
    }
  end

  def test_list
    get :list, :lang => "ja"
    assert_html("ja/list.html")
    assert_response :success

    get :list, :lang => "en"
    assert_html("en/list.html")

    # not match
    get :list, :lang => "kr"
    assert_html("en/list.html")

    # list_fr.rhtml
    get :list, :lang => "fr"
    assert_html("fr/list.html")
  end

  def test_show
    get :show, :id => @first_id, :lang => "ja"

    assert_html("ja/show.html")
    assert_response :success
    assert_not_nil assigns(:article)
    assert assigns(:article).valid?

    get :show, :id => @first_id, :lang => "en"
    assert_html("en/show.html")
  end

  def test_new
    get :new, :lang => "ja"
    assert_html("ja/new.html")
    assert_response :success
    assert_not_nil assigns(:article)

    get :new, :lang => "en"
    assert_html("en/new.html")
    assert_response :success
    assert_not_nil assigns(:article)

    get :new, :lang => "fr"
    assert_html("fr/new.html")
    assert_response :success
    assert_not_nil assigns(:article)
  end

  def test_create_error
    post :create, :article => {:title => "", :description => "", :lastupdate => Date.new(2007, 4, 1)}, :lang => "ja"
    assert_html("ja/create_error.html")

    post :create, :article => {:title => "", :description => "", :lastupdate => Date.new(2007, 4, 1)}, :lang => "en"
    assert_html("en/create_error.html")
  end

  def test_multi_error_messages_for
    post :multi_error_messages_for, :article => {:article_title => "", :article_description => "", :user_name => ""}, :lang => "ja"
    assert_html("ja/multi_error_messages_for.html")

    post :multi_error_messages_for, :article => {:article_title => "", :article_description => "", :user_name => ""}, :lang => "en"
    assert_html("en/multi_error_messages_for.html")
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Article.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Article.find(@first_id)
    }
  end
end
