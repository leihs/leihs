require File.dirname(__FILE__) + '/../test_helper'
require 'kaufvorgangs_controller'

# Re-raise errors caught by the controller.
class KaufvorgangsController; def rescue_action(e) raise e end; end

class KaufvorgangsControllerTest < Test::Unit::TestCase
	
  fixtures :kaufvorgangs, :gegenstands, :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = KaufvorgangsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
		@request.host = 'localhost'
		@request.session[ :user ] = users( :magnus )
  end

  def test_index
    get :index
    assert_redirected_to :controller => 'gegenstands', :action => 'list'
  end

  def test_show
    get :show, 'id' => 1
    assert_template 'show'
    assert @response.has_template_object?( 'kaufvorgang' )
    assert assigns( :kaufvorgang ).valid?
  end

  def test_new
    get :new, :id => 1
    assert_template 'new'
    assert @response.has_template_object?( 'kaufvorgang' )
  end

  def test_create
    num_kaufvorgangs = Kaufvorgang.count

    post :create, { :id => 1, :kaufvorgang => { } }
    assert_redirected_to :controller => 'gegenstands', :action => 'list'

    assert_equal num_kaufvorgangs + 1, Kaufvorgang.count
  end

  def test_edit
    get :edit, 'id' => 1
    assert_template 'edit'
    assert @response.has_template_object?( 'kaufvorgang' )
    assert assigns( :kaufvorgang ).valid?
  end

  def test_update
    post :update, 'id' => 1
    assert_redirected_to :controller => 'gegenstands', :action => 'edit', :id => 1
  end

  def test_destroy
    assert_not_nil Kaufvorgang.find( 1 )

    post :destroy, :id => 1
    assert_redirected_to :controller => 'gegenstands', :action => 'edit', :id => 1

    assert_raise(ActiveRecord::RecordNotFound) {
      kaufvorgang = Kaufvorgang.find(1)
    }
  end
end
