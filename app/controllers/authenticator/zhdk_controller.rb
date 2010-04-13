require 'net/http' 
require 'net/https'
require 'cgi'
class Authenticator::ZhdkController < Authenticator::AuthenticatorController
  
  
  AUTHENTICATION_URL = 'http://www.zhdk.ch/?auth/leihs2'
  APPLICATION_IDENT = '7f6d33ca2ad44359c826e2337d9315b1'
  DEFAULT_INVENTORY_POOLS = ["ITZ-Ausleihe", "AV-Ausleihe"]
  SUPER_USERS = ["e157339|zhdk", "e159123|zhdk", "e10262|zhdk", "e162205|zhdk", "e171014|zhdk"] #Jerome, Franco, Ramon, Tomáš
  AUTHENTICATION_SYSTEM_CLASS_NAME = "Zhdk"
  
  def login_form_path
    "/authenticator/zhdk/login"
  end
  
  def login
    redirect_to target
  end
  
  def target
    AUTHENTICATION_URL + "&url_postlogin=" + CGI::escape("http://#{request.host}:#{request.port}#{url_for('/authenticator/zhdk/login_successful/%s')}")
  end
  
  def login_successful(session_id = params[:id])
    response = fetch("#{AUTHENTICATION_URL}/response&agw_sess_id=#{session_id}&app_ident=#{APPLICATION_IDENT}")
    if response.code.to_i == 200
      xml = Hash.from_xml(response.body)
      #old# uid = xml["authresponse"]["person"]["uniqueid"]
      self.current_user = create_or_update_user(xml)
      redirect_back_or_default("/") # TODO #working here#24
    else
      render :text => "Authentication Failure. HTTP connection failed - response was #{response.code}" 
    end
  end
    
  def create_or_update_user(xml)
    uid = xml["authresponse"]["person"]["uniqueid"]
    email = xml["authresponse"]["person"]["email"] || uid + "@leihs.zhdk.ch"
    firstname = "#{xml['authresponse']['person']['firstname']}"
    lastname = "#{xml["authresponse"]["person"]["lastname"]}"
    phone = "#{xml["authresponse"]["person"]["phone_mobile"]}"
    phone = "#{xml["authresponse"]["person"]["phone_business"]}" if phone.blank?
    phone = "#{xml["authresponse"]["person"]["phone_private"]}" if phone.blank?
    user = User.find(:first, :conditions => { :unique_id => uid }) || User.find(:first, :conditions => { :email => email }) || User.new
    user.unique_id = uid
    user.email = email
    user.login = "#{firstname} #{lastname}"
    user.firstname = firstname
    user.lastname = lastname
    user.phone = phone
    user.authentication_system = AuthenticationSystem.find(:first, :conditions => {:class_name => AUTHENTICATION_SYSTEM_CLASS_NAME })
    user.extended_info = xml["authresponse"]["person"]
    if user.new_record?
      user.save
      r = Role.find(:first, :conditions => {:name => "customer"})
      ips = InventoryPool.find(:all, :conditions => {:name => DEFAULT_INVENTORY_POOLS})
      ips.each do |ip|
        user.access_rights.create(:role => r, :inventory_pool => ip)
      end
    else
      user.save
    end
    
    if SUPER_USERS.include?(user.unique_id)
      r = Role.find(:first, :conditions => {:name => "admin"})    
      user.access_rights.create(:role => r, :inventory_pool => nil)
    end
    user
  end
  
  private 
  
  def fetch(uri_str, limit = 10)
     raise ArgumentError, 'HTTP redirect too deep' if limit == 0

     uri = URI.parse(uri_str)
     http = Net::HTTP.new(uri.host, uri.port)
     http.use_ssl = true if uri.port == 443
     response = http.get(uri.path + "?" + uri.query, nil)
     case response
     when Net::HTTPSuccess     then response
     when Net::HTTPRedirection then fetch(response['location'], limit - 1)
     else
         response.error!
     end
  end
  
end
