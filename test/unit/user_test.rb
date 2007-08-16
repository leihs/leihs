require File.dirname(__FILE__) + '/../test_helper'

# Set salt to 'change-me' because thats what the fixtures assume. 
User.salt = 'change-me'

class UserTest < Test::Unit::TestCase
  
  fixtures :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true
  
	def test_prefix_suffix
		u = User.new
		assert_equal "", u.email.to_s
		assert_equal "", u.email_prefix
		assert_equal "", u.email_suffix
		
		u.email_prefix = "kurt.felix"
		assert_equal "kurt.felix@", u.email
		assert_equal "", u.email_suffix
		
		u.email = ""
		u.email_suffix = "hgkz.ch"
		assert_equal "@hgkz.ch", u.email
		assert_equal "", u.email_prefix
		
		u.login = "hanne"
		u.nachname = "Meister"
		u.abteilung = "SBD"
		u.email = "hans.meister@hmt.edu"
		assert u.valid?
		assert_equal "hans.meister", u.email_prefix
		assert_equal "hmt.edu", u.email_suffix, 
		
		u.email_prefix = "tina.tuner"
		assert_equal "tina.tuner@hmt.edu", u.email
		assert_equal "hmt.edu", u.email_suffix
		
		u.email_suffix = "hgkz.net"
		assert_equal "tina.tuner@hgkz.net", u.email
		assert_equal "tina.tuner", u.email_prefix
		
		u.email_prefix = ""
		u.email_suffix = ""
		assert_equal "", u.email
	end
	
  def test_auth
    assert_equal @bob, User.authenticate("bob", "test")    
    assert_nil User.authenticate("nonbob", "test")
  end

  def test_disallowed_passwords
    
    u = User.new    
    u.login = "nonbob"

    u.password = u.password_confirmation = "tiny"
    assert !u.save     
    #assert u.errors.invalid?('password')

    u.password = u.password_confirmation = "hugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehugehuge"
    assert !u.save     
    #assert u.errors.invalid?('password')
        
    u.password = u.password_confirmation = ""
    assert !u.save    
    #assert u.errors.invalid?('password')
		
    u.password = u.password_confirmation = "bobs_secure_password"
    #assert u.save
    #assert u.errors.empty?
	end
  
  def test_bad_logins

    u = User.new  
    u.password = u.password_confirmation = "bobs_secure_password"

    u.login = "x"
    assert !u.save     
    assert u.errors.invalid?( 'login' )
    
    u.login = "hugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhugebobhug"
    assert !u.save     
    assert u.errors.invalid?('login')

    u.login = ""
    assert !u.save
    assert u.errors.invalid?('login')

    u.login = "okbob"
    #assert u.save  
    #assert u.errors.empty?
      
  end

  def test_collision
    u = User.new
    u.login      = "existingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    assert !u.save
  end

  def test_create
    u = User.new
    u.login      = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
		u.vorname = "Kunos"
		u.nachname = "Matter"
		u.email = "km@hier.ch"
		u.telefon = "+41 43 446 2345"
		u.postadresse = "auch eine"
		u.abteilung = "SNM"
		u.benutzerstufe = 1
      
    assert u.save  
  end
  
  def test_sha1
    u = User.new
    u.login = "nonexistingbob"
    u.password = u.password_confirmation = "bobs_secure_password"
    #assert u.save
        
    #assert_equal '98740ff87bade6d895010bceebbd9f718e7856bb', u.password    
  end

end
