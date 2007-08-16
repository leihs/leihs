require File.dirname(__FILE__) + '/../test_helper'
require 'users_controller'

# Re-raise errors caught by the controller.
class UsersController; def rescue_action(e) raise e end; end

class UsersControllerTest < Test::Unit::TestCase
	
	fixtures :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true
	
  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_list_student
    @request.session[ :user ] = users( :normaler_student )
		get :list

    assert_kein_zugang
	end
	
	def test_list_root
    @request.session[ :user ] = users( :magnus )
		get :list

		assert_response :success
    assert_template 'list'
    assert_not_nil assigns( :users )
  end

	def test_update
		post :update, { :id => 10, :user => {} }
		
		assert_kein_zugang
	end
	
	def test_update_student
		testuser = users( :student_ohne_ident )
		assert testuser.valid?
    @request.session[ :user ] = users( :magnus )
		@request.session[ :aktiver_geraetepark ] = 1
		
		testuser.vorname = 'Hanns'
		testuser.abteilung = 'KKK'
		testuser.telefon = '333 888 222 777'
		testuser.password = ''
		testuser.password_confirmation = ''
		assert testuser.valid?
		post :update, { :id => testuser.id, :user => testuser.attributes }
		
		assert_not_nil assigns( :user )
		assert assigns( :user ).is_a?( User )
		assert assigns( :user ).valid_generell?
		assert_equal 0, assigns( :user ).errors.count
		assert_equal assigns( :user ), testuser

		assert_redirected_to :action => 'list'
	end

end
