require File.dirname(__FILE__) + '/../test_helper'
require 'hw_inventars_controller'

# Re-raise errors caught by the controller.
class HwInventarsController; def rescue_action(e) raise e end; end

class HwInventarsControllerTest < Test::Unit::TestCase
  
	fixtures :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = HwInventarsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
		@request.session[ :user ] = users( :magnus )
  end

  def test_index
    #get :index
    #assert_template 'list'
  end

  def test_list
    #get :list
    #assert_template 'list'
    #assert @response.has_template_object?( 'hw_inventars' )
  end

	def test_list_att
		#get :list_att, :abt => 'AVZ'
		#assert_response :success
		#assert_template 'list'
		#assert @response.has_template_object?( 'hw_inventars' )
	end

  def test_show
    #get :show, 'id' => 1
    #assert_template 'show'
    #assert @response.has_template_object?( 'hw_inventars' )
    #assert assigns( :hw_inventar ).valid?
  end

	def test_sync
		# nur manchmal ausführen... braucht viel Zeit
		
		#get :sync
		#assert_template 'sync'
		#assert @response.has_template_object?( 'hw_inventars' )
	end
	
	def test_mach_pakete
		# nur manchmal ausführen... braucht viel Zeit
		
		#get :mach_pakete
		#assert_template 'mach_pakete'
		#assert @response.has_template_object?( 'gegenstands' )
	end
		
end
