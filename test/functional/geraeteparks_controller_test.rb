require File.dirname(__FILE__) + '/../test_helper'
require 'geraeteparks_controller'

# Re-raise errors caught by the controller.
class GeraeteparksController; def rescue_action(e) raise e end; end

class GeraeteparksControllerTest < Test::Unit::TestCase
	
  fixtures :geraeteparks, :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = GeraeteparksController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_edit
    get :edit, :id => 1
    assert_kein_zugang
  end

  def test_edit_student
		@request.session[ :user ] = users( :normaler_student )
    get :edit, :id => 1
		assert_kein_zugang
	end

  def test_edit_admin
		@request.session[ :user ] = users( :magnus )
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns( :geraetepark )
    assert assigns( :geraetepark ).valid?
  end

  def test_update
    get :update, :id => 1
    assert_kein_zugang
  end

  def test_update_student
		@request.session[ :user ] = users( :normaler_student )
    get :update, :id => 1
		assert_kein_zugang
	end

  def test_update_admin
		@request.session[ :user ] = users( :magnus )
    post :update, { :id => 1, :geraetepark => { :id => 1, :name => 'AVZ', :logo_url => 'http://iad.hgkz.ch/bilder/2553.jpg' } }

    assert_response :redirect
    assert_redirected_to :controller => 'haupt', :action => 'info'
  end

end
