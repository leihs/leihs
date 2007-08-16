require File.dirname(__FILE__) + '/../test_helper'
require 'admin_controller'

# Re-raise errors caught by the controller.
class AdminController; def rescue_action(e) raise e end; end

class AdminControllerTest < Test::Unit::TestCase
	
  fixtures :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = AdminController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_status
    get :status
    assert_kein_zugang
  end

  def test_status_student
		@request.session[ :user ] = users( :normaler_student )
    get :status
		assert_kein_zugang
	end
	
  def test_status_admin
		@request.session[ :user ] = users( :magnus )
    get :status

		assert_response :success
    assert_template 'status'
	end
	
end
