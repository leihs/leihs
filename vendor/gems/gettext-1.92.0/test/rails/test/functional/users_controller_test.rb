require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

unless defined? RESULT_DIR
  RESULT_DIR = File.dirname(__FILE__) + "/../../test/result/"
end

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

  def test_custom_error_message
    get :custom_error_message, :lang => "ja"
    assert_html("ja/custom_error_message.html")
    assert_response :success

    get :custom_error_message, :lang => "en"
    assert_html("en/custom_error_message.html")

    # not match
    get :custom_error_message, :lang => "kr"
    assert_html("en/custom_error_message.html")

    # custom_error_message_fr.html.erb
    get :custom_error_message, :lang => "fr"
    assert_html("fr/custom_error_message.html")
  end

  def test_custom_error_message_with_plural
    get :custom_error_message, :lang => "ja", :plural => "true"
    assert_html("ja/custom_error_message_with_plural.html")
    assert_response :success

    get :custom_error_message, :lang => "en", :plural => "true"
    assert_html("en/custom_error_message_with_plural.html")

    get :custom_error_message, :lang => "fr", :plural => "true"
    assert_html("fr/custom_error_message_with_plural.html")

  end
end
