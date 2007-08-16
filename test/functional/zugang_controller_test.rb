require File.dirname(__FILE__) + '/../test_helper'
require 'zugang_controller'

# Set salt to 'change-me' because thats what the fixtures assume. 
User.salt = 'change-me'

# Raise errors beyond the default web-based presentation
class ZugangController; def rescue_action(e) raise e end; end

class ZugangControllerTest < Test::Unit::TestCase
  
  fixtures :users, :geraeteparks_users
  
	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = ZugangController.new
    @request = ActionController::TestRequest.new
		@response = ActionController::TestResponse.new
    @request.host = "localhost"
  end
  
	def test_abruf_index
		get :index
		assert_redirected_to :action => 'login'
	end
	def test_abruf_login
		get :login
		assert_response :success
	end
	def test_abruf_signup
		get :signup
		assert_response :success
	end
	def test_abruf_aktivieren
		get :aktivieren
		assert_redirected_to :action => 'login'
		assert_not_nil flash[ :notice ]
		assert flash[ :notice ].include?( 'nicht aktiviert' )
	end
	
  def test_auth_importer
    @request.session[ :return_to ] = "/pakets/list"
    post :login, :user_login => "importer", :user_password => "test"

    assert_not_nil session[ :user ]
    assert_kind_of User, session[ :user ]
		assert_equal session[ :user ], users( :importer )
    #assert_redirected_to :controller => 'pakets', :action => 'list'
  end
  def test_auth_magnus
    post :login, :user_login => "magnus", :user_password => "test"

		assert_not_nil session[ :user ]
    assert_kind_of User, session[ :user ]
    assert_equal users( :magnus ), @response.session[ :user ]
    assert_redirected_to :controller => 'admin', :action => 'status'
  end
  def test_auth_hans
    @request.session[ :return_to ] = "/bogus/location"
    post :login, :user_login => "hansdam", :user_password => "test"

		assert_not_nil session[ :user ]
		assert_not_nil session[ :aktiver_geraetepark ]
    assert_equal users( :hans_dampf ), @response.session[ :user ]
    #assert_redirected_to :controller => 'bogus', :action => 'location'
  end
	
	def test_signup
		testuser = User.new( {
					:vorname => 'Bob',
					:nachname => 'New',
					:abteilung => 'SVG',
					:email_prefix => 'bob.new',
					:email_suffix => 'hgkz.ch',
					:password => "newpassword",
					:password_confirmation => "newpassword",
					:telefon => '3256',
					:postadresse => 'in der hgk Z drinnen' } )
		assert testuser.valid_generell?
		assert testuser.valid_fuer_signup?
		
		post :signup, :user => testuser.attributes
		assert_response :success
		assert_template 'signup_ok'
		
		assert_not_nil assigns( :user )
		assert 0, assigns( :user ).errors.count
		assert assigns( :user ).valid_fuer_signup?
  end
	def test_bad_signup
		# Versuch ohne Vorname
		versuch = mach_korrekten_signup
		versuch[ :vorname ] = nil
    post :signup, :user => versuch
    assert_not_nil assigns( :user ).errors.on( :vorname )
    assert_response :success
    
		# Versuch ohne Nachname
		versuch = mach_korrekten_signup
		versuch[ :nachname ] = nil
    post :signup, :user => versuch
    assert_not_nil assigns( :user ).errors.on( :nachname )
    assert_response :success
    
		# Versuch ohne Abteilung
		versuch = mach_korrekten_signup
		versuch[ :abteilung ] = nil
    post :signup, :user => versuch
    assert_not_nil assigns( :user ).errors.on( :abteilung )
    assert_response :success
    
		# Versuch ohne eMail Prefix
		versuch = mach_korrekten_signup
		versuch[ :email_prefix ] = ''
    post :signup, :user => versuch
    assert_not_nil assigns( :user ).errors.on( :email )
    assert_response :success
    
		# Versuch ohne Password
		versuch = mach_korrekten_signup
		versuch[ :password ] = 'kurz'
    post :signup, :user => versuch
    assert_not_nil assigns( :user ).errors.on( :password )
    assert_response :success
    
		# Versuch ohne Telefon
		versuch = mach_korrekten_signup
		versuch[ :telefon ] = '123'
    post :signup, :user => versuch
    assert_not_nil assigns( :user ).errors.on( :telefon )
    assert_response :success
    
		# Versuch ohne Postadresse
		versuch = mach_korrekten_signup
		versuch[ :postadresse ] = 'hier da'
    post :signup, :user => versuch
    assert_not_nil assigns( :user ).errors.on( :postadresse )
    assert_response :success
  end

  def test_invalid_login
    post :login, :user_login => "bob", :user_password => "not_correct"
     
    assert_nil session[ :user ]
    assert_template 'login'
  end
  
	def test_login_logoff
		post :login, :user_login => "importer", :user_password => "test"
		assert_not_nil session[ :user ]

		#get :logout
		#assert_nil session[ :user ]
	end
		
end