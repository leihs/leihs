require File.dirname(__FILE__) + '/../test_helper'

class ArticlesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:articles)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_article
    assert_difference('Article.count') do
      post :create, :article => {
                  "title"=>"aaaaaaaaaa",
                  "lastupdate"=> Time.now,
                  "description"=>"aaaaaaaaaa" }
    end

    assert_redirected_to article_path(assigns(:article))
  end

  def test_should_show_article
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end

  def test_should_update_article
    put :update, :id => 1, :article => { 
                  "title"=>"aaaaaaaaaa",
                  "lastupdate"=> Time.now,
                  "description"=>"aaaaaaaaaa" }
    assert_redirected_to article_path(assigns(:article))
  end

  def test_should_destroy_article
    assert_difference('Article.count', -1) do
      delete :destroy, :id => 1
    end

    assert_redirected_to articles_path
  end
end
