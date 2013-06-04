# In order to use this Shibboleth authenticator, you must put the entire
# leihs instance behind a shibboleth "secure" location:
#
# <Location />
#    AuthType shibboleth
#    ShibRequireSession On
#    require valid-user
#  </Location>
#
# You must also have a working service provider (SP) for this instance.

class Authenticator::ShibbolethAuthenticationController < Authenticator::AuthenticatorController

  DEFAULT_INVENTORY_POOLS = ["ITZ-Ausleihe", "AV-Ausleihe"]
  SUPER_USERS = ["e157339@zhdk.ch", "e159123@zhdk.ch", "e10262@zhdk.ch", "e162205@zhdk.ch", "e171014@zhdk.ch"] #Jerome, Franco, Ramon, Tomáš
  AUTHENTICATION_SYSTEM_CLASS_NAME = "ShibbolethAuthentication"

  layout 'layouts/backend/general'

  def login_form_path
    "/authenticator/shibboleth/login"
  end
  
  def login
    super
    # This point should only be reached after a successful login from Shibboleth.
    # Shibboleth handles all error management, so we don't need to worry about any
    # of that.
  
    if ENV['uniqueID'].blank? 
      redirect_to login_form_path 
    else
      self.current_user = create_or_update_user 
      redirect_to root_path 
    end
  end  

  def create_or_update_user

    # ENV after Shibboleth authentication looks like this:
#    "uniqueID"=>"e10262@zhdk.ch", 
#    "homeOrganizationType"=>"uas", 
#    "givenName"=>"Ramon", 
#    "Shib-AuthnContext-Class"=>"urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport", 
#    "Shib-Identity-Provider"=>"https://aai-logon.zhdk.ch/idp/shibboleth", 
#    "Shib-InetOrgPerson-givenName"=>"Ramon", 
#    "Shib-Authentication-Method"=>"urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport", 
#    "mail"=>"ramon.cahenzli@zhdk.ch", 
#    "Shib-SwissEP-HomeOrganization"=>"zhdk.ch", 
#    "Shib-Application-ID"=>"leihs2shib", 
#    "Shib-Person-surname"=>"Cahenzli", 
#    "Shib-EP-Affiliation"=>"faculty;staff;member", 
#    "Shib-Authentication-Instant"=>"2010-09-28T07:03:59.738Z", 
#    "Shib-SwissEP-UniqueID"=>"e10262@zhdk.ch", 
#    "Shib-SwissEP-HomeOrganizationType"=>"uas", 
#    "Shib-InetOrgPerson-mail"=>"ramon.cahenzli@zhdk.ch", 
#    "Shib-Session-ID"=>"_22d5e2f708f663eae29d2afeae08dfff", 
#    "surname"=>"Cahenzli", "homeOrganization"=>"zhdk.ch", 
#    "affiliation"=>"faculty;staff;member" 


    uid = ENV['uniqueID'] 
    email = ENV['mail'] || uid + "@leihs.zhdk.ch"
    user = User.where(:unique_id => uid).first || User.where(:email => email).first || User.new
    user.unique_id = uid
    user.email = email
    user.firstname = "#{ENV['givenName']}"
    user.lastname = "#{ENV['surname']}"
    user.login = "#{user.firstname} #{user.lastname}"
    user.authentication_system = AuthenticationSystem.where(:class_name => AUTHENTICATION_SYSTEM_CLASS_NAME).first
    if user.new_record?
      user.save
      r = Role.where(:name => "customer").first
      ips = InventoryPool.where(:name => DEFAULT_INVENTORY_POOLS)
      ips.each do |ip|
        user.access_rights.create(:role => r, :inventory_pool => ip)
      end
    else
      user.save
    end

    if SUPER_USERS.include?(user.unique_id)
      r = Role.where(:name => "admin").first
      user.access_rights.create(:role => r, :inventory_pool => nil)
    end
    user
  end

  
end
