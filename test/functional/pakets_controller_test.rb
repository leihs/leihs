require File.dirname(__FILE__) + '/../test_helper'
require 'pakets_controller'

# Re-raise errors caught by the controller.
class PaketsController; def rescue_action(e) raise e end; end

class PaketsControllerTest < Test::Unit::TestCase
	
	fixtures :pakets, :users
	
	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = PaketsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'list'
	end
	
	def test_index_student
		@request.session[ :user ] = users( :normaler_student )
    get :index

    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'
    assert_not_nil assigns( :pakets )
  end

  def test_list_student
    @request.session[ :user ] = users( :normaler_student )
		get :list

    assert_response :success
    assert_template 'list'
    assert_not_nil assigns( :pakets )
  end

  def test_show_student
    @request.session[ :user ] = users( :normaler_student )
    get :show, :id => 1

		assert_response :success
	end
	
	def test_show_root
    @request.session[ :user ] = users( :magnus )
		get :show, :id => 1
		
    assert_response :success
    assert_template 'show'

    assert_not_nil assigns( :paket )
    assert assigns( :paket ).valid?
  end

  def test_new
    get :new

    assert_response :redirect
  end

  def test_create
		# normaler student hat keinen Zugang
    @request.session[ :user ] = users( :normaler_student )
		post :create, :reservation => {}
		
		assert_redirected_to :controller => 'zugang', :action => 'login'

		# root hat Zugang
    @request.session[ :user ] = users( :magnus )
		post :create, :reservation => {}
		
    assert_redirected_to :action => 'list'
  end

  def test_edit
		# normaler student kann Seite nicht abrufen
	  @request.session[ :user ] = users( :normaler_student )
    get :edit, :id => 1

    assert_redirected_to :controller => 'zugang', :action => 'login'
	end
	
	def test_edit_root
		# root kann Seite abrufen
		@request.session[ :user ] = users( :magnus )
    get :edit, :id => 1

		assert_response :success
    assert_template 'edit'

    assert_not_nil assigns( :paket )
    assert assigns( :paket ).valid?
  end

  def test_update_student
		@request.session[ :user ] = users( :normaler_student )
		post :update, :id => 1
		assert_kein_zugang
  end

  def test_destroy
    assert_not_nil Paket.find( 4 )

    @request.session[ :user ] = users( :magnus )
    post :destroy, :id => 4

    assert_response :redirect
    assert_redirected_to :action => 'list'

		assert_raise(ActiveRecord::RecordNotFound) {
			Paket.find( 4 )
		}
  end
end
