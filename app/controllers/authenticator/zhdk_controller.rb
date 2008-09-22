require 'net/http' 
require 'net/https'

class Authenticator::ZhdkController < Authenticator::AuthenticatorController
  
  
  AUTHENTICATION_URL = 'http://www.zhdk.ch/?auth/leihs2'
  APPLICATION_IDENT = '7f6d33ca2ad44359c826e2337d9315b1'
  DEFAULT_INVENTORY_POOLS = ["AVZ", "ITZ"]
  SUPER_USERS = ["e157339|zhdk", "e159123|zhdk", "e10262|zhdk"] #Jerome, Franco, Ramon
  
  def login_form_path
    "/authenticator/zhdk/login"
  end
  
  def login
    redirect_to AUTHENTICATION_URL
  end
  
  def login_successful(session_id = params[:id])
    response = fetch("#{AUTHENTICATION_URL}/response&agw_sess_id=#{session_id}&app_ident=#{APPLICATION_IDENT}")
    if response.code.to_i == 200
      xml = Hash.from_xml(response.body)
      uid = xml["authresponse"]["person"]["uniqueid"]
      self.current_user = User.find(:first, :conditions => { :unique_id => uid }) || generate_new_user(xml) #TODO: Update Information that changes (groups, email etc.)
      redirect_back_or_default("/")
    else
      render :text => "Authentication Failure. HTTP connection failed - response was #{response.code}" 
    end
  end
  
  
  def generate_new_user(xml)

    user = User.new(:email => xml["authresponse"]["person"]["email"],
                       :login => "#{xml['authresponse']['person']['firstname']} #{xml["authresponse"]["person"]["lastname"]}")
    user.unique_id = xml["authresponse"]["person"]["uniqueid"]
    user.save
    r = Role.find(:first, :conditions => {:name => "student"})
    ips = InventoryPool.find(:all, :conditions => {:name => DEFAULT_INVENTORY_POOLS})
    ips.each do |ip|
      user.access_rights << AccessRight.new(:role => r, :inventory_pool => ip)
    end
    
    if SUPER_USERS.include?(user.unique_id)
      r = Role.find(:first, :conditions => {:name => "admin"})    
      user.access_rights << AccessRight.new(:role => r, :inventory_pool => nil)
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