require File.dirname(__FILE__) + '/../test_helper'
require 'haupt_controller'

# Re-raise errors caught by the controller.
class HauptController; def rescue_action(e) raise e end; end

class HauptControllerTest < Test::Unit::TestCase
	
	fixtures :users, :geraeteparks_users
	
	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true
	
  def setup
    @controller = HauptController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
		@request.host = 'localhost'
  end

  # Replace this with your real tests.
  def test_index
		get :index
		
    assert_response :success
  end

  def test_setze_berechtigung
		get :setze_berechtigung, :id => 1
		
    assert_kein_zugang
	end
	def test_setze_berechtigung_student
		@request.session[ :user ] = users( :normaler_student )
		@request.session[ :aktiver_geraetepark ] = 1
		get :setze_berechtigung, :id => 4
		
		assert_redirected_to :controller => 'haupt', :action => 'info'
		assert_equal 4, @response.session[ :aktiver_geraetepark ]
  end
	def test_setze_ungueltige_berechtigung_student
		@request.session[ :user ] = users( :normaler_student )
		@request.session[ :aktiver_geraetepark ] = 1
		get :setze_berechtigung, :id => 3
		
		assert_redirected_to :controller => 'haupt', :action => 'info'
		assert_not_equal 3, @response.session[ :aktiver_geraetepark ]
	end
	def test_setze_berechtigung_herausgeber
		@request.session[ :user ] = users( :normaler_herausgeber )
		get :setze_berechtigung, :id => 4
		assert_redirected_to :controller => 'admin', :action => 'status'
		assert_equal 4, @response.session[ :aktiver_geraetepark ]
  end
	
  def test_testmail
		get :testmail
		
    assert_redirected_to :controller => 'zugang', :action => 'login'
	end
	def test_testmail_von_admin
		@request.session[ :user ] = users( :magnus )
		get :testmail, :id => 1
		
		assert_response :success
  end

	def test_edit_mich
		get :edit_mich
		
		assert_kein_zugang
	end
	def test_edit_mich_student
		@request.session[ :user ] = users( :normaler_student )
		@request.session[ :aktiver_geraetepark ] = 1
		get :edit_mich
		
		assert_response :success
		assert_template 'edit_mich'
		assert_not_nil assigns( :user )
		assert assigns( :user ).is_a?( User )
		#assert_valid assigns( :user )	kein gueltiges Password bei Abruf
	end
	
	def test_update_mich
		post :update_mich, { :user => {} }
		
		assert_kein_zugang
	end
	def test_update_mich_student
		testuser = users( :normaler_student )
		assert testuser.valid?
		@request.session[ :user ] = testuser
		@request.session[ :aktiver_geraetepark ] = 1
		
		testuser.vorname = 'Hanns'
		testuser.abteilung = 'KKK'
		testuser.telefon = '333 888 222 777'
		testuser.password = ''
		testuser.password_confirmation = ''
		assert testuser.valid?
		post :update_mich, { :user => testuser.attributes }
		
		assert_not_nil assigns( :user )
		assert assigns( :user ).is_a?( User )
		assert assigns( :user ).valid?
		assert_equal assigns( :user ), testuser

		assert_redirected_to :action => 'status'
	end
	def test_update_mich_student_password
		testuser = users( :normaler_student )
		assert testuser.valid?
		@request.session[ :user ] = testuser
		@request.session[ :aktiver_geraetepark ] = 1
		
		testuser.password = 'neues_password'
		testuser.password_confirmation = 'neues_password'
		post :update_mich, { :user => testuser.attributes }
		
		assert_not_nil assigns( :user )
		assert assigns( :user ).is_a?( User )
		assert assigns( :user ).valid?
		
		reloader = User.find( testuser.id )
		assert_equal reloader.password, User.sha1( testuser.password )
		
		assert_redirected_to :action => 'status'
	end
		
end
