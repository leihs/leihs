require File.dirname(__FILE__) + '/../test_helper'
require 'gegenstands_controller'

# Re-raise errors caught by the controller.
class GegenstandsController; def rescue_action(e) raise e end; end

class GegenstandsControllerTest < Test::Unit::TestCase
	
  fixtures :gegenstands, :kaufvorgangs, :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = GegenstandsController.new
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
    assert @response.has_template_object?( 'gegenstands' )
  end

  def test_show
    get :show, 'id' => 1
    assert_template 'show'
    assert @response.has_template_object?( 'gegenstands' )
    assert assigns( :gegenstand ).valid?
  end

  def test_new
    get :new
    assert_template 'new'
    assert @response.has_template_object?( 'gegenstands' )
  end

  def test_create_ohne_params
    num_gegenstands = Gegenstand.count
    post :create, 'gegenstand' => { }

    assert_response :success
		assert_template 'new'
		assert_tag :tag => 'div', :attributes => { :id => 'errorExplanation' }
  end

  def test_create
    num_gegenstands = Gegenstand.count
    post :create, 'gegenstand' => { :modellbezeichnung => 'Kabel XLR 10m', :inventar_abteilung => 'AB', :herausgabe_abteilung => 'CD' }

    assert_redirected_to :action => 'list'
    assert_equal num_gegenstands + 1, Gegenstand.count
  end

  def test_edit
    get :edit, 'id' => 1
    assert_template 'edit'
    assert @response.has_template_object?( 'gegenstands' )
    assert assigns( :gegenstand ).valid?
  end

  def test_update
    #post :update, { 'id' => 1, 'gegenstand' => {} }
    #assert_redirected_to :action => 'list'
  end

  def test_destroy
    assert_not_nil Gegenstand.find(1)

    post :destroy, 'id' => 1
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      gegenstand = Gegenstand.find(1)
    }
  end

end
