require File.dirname(__FILE__) + '/../test_helper'
require 'computerdatens_controller'

# Re-raise errors caught by the controller.
class ComputerdatensController; def rescue_action(e) raise e end; end

class ComputerdatensControllerTest < Test::Unit::TestCase
	
  fixtures :computerdatens, :gegenstands, :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = ComputerdatensController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

		@request.session[ :user ] = users( :magnus )
  end

  def test_index
    get :index
    assert_template 'list'
  end

  def test_list
    get :list
    assert_template 'list'
    assert @response.has_template_object?( 'computerdatens' )
  end

  def test_show
    get :show, 'id' => 1
    assert_template 'show'
    assert @response.has_template_object?( 'computerdatens' )
    assert assigns( :computerdaten ).valid?
  end

  def test_new
    get :new, :id => 3
    assert_template 'new'
    assert @response.has_template_object?( 'computerdatens' )
  end

  def test_create
    num_computerdatens = Computerdaten.count

    #post :create, { :id => 3, 'computerdaten' => { } }
    #assert_redirected_to :action => 'list'
    #assert_equal num_computerdatens + 1, Computerdaten.count
  end

  def test_edit
    get :edit, 'id' => 1
    assert_template 'edit'
    assert @response.has_template_object?( 'computerdatens' )
    assert assigns( :computerdaten ).valid?
  end

  def test_update
    #post :update, 'id' => 3
    #assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Computerdaten.find( 1 )

    #post :destroy, 'id' => 1
    #assert_redirected_to :action => 'list'

    #assert_raise(ActiveRecord::RecordNotFound) {
      #computerdaten = Computerdaten.find(1)
    #}
  end
end
