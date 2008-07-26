require File.dirname(__FILE__) + '<%= '/..' * class_nesting_depth %>/../test_helper'

# make sure the secret for request forgery protection is set (views will
# explicitly use the form_authenticity_token method which will fail otherwise)
<%= controller_class_name %>Controller.request_forgery_protection_options[:secret] = 'test_secret'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    get :index, :format => 'ext_json'
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_<%= file_name %>
    assert_difference('<%= class_name %>.count') do
      xhr :post, :create, :format => 'ext_json', :<%= file_name %> => { }
    end

    assert_not_nil flash[:notice]
    assert_response :success
  end

  def test_should_show_<%= file_name %>
    get :show, :id => <%= table_name %>(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => <%= table_name %>(:one).id
    assert_response :success
  end

  def test_should_update_<%= file_name %>
    xhr :put, :update, :format => 'ext_json', :id => <%= table_name %>(:one).id, :<%= file_name %> => { }
    assert_not_nil flash[:notice]
    assert_response :success
  end

  def test_should_destroy_<%= file_name %>
    assert_difference('<%= class_name %>.count', -1) do
      xhr :delete, :destroy, :id => <%= table_name %>(:one).id
    end

    assert_response :success
  end
end
