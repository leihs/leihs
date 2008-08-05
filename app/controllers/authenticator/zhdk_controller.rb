require 'net/http' 

class Authenticator::ZhdkController < Authenticator::AuthenticatorController
  
  
  #AUTHENTICATION_URL = 'http://www.zhdk.ch/?auth/ithelp'
  AUTHENTICATION_URL = 'http://localhost:3000/backend/temporary/login'
  
  def login_form_path
    "/authenticator/zhdk/login"
  end
  
  def login
    redirect_to AUTHENTICATION_URL
  end
  
  def login_successfull(session_id = params[:id])
    Net::HTTP.start("www.zhdk.ch") do |http| 
      #response = http.get('test2/?auth/ithelp/response/#{session_id}') 
      response = http.get('/test2/upload/tester1.xml')
      if response.code.to_i == 200
        xml = Hash.from_xml(response.body)
        uid = xml["authresponse"]["person"]["uniqueid"]
        self.current_user = User.find(:first, :conditions => { :unique_id => uid }) || generate_new_user(xml)
        redirect_back_or_default("/")
      else
        render :text => "Authentication Failure. HTTP connection failed - response was #{response.code}" 
      end
    end
  end
  
  
  def generate_new_user(xml)

    user = User.create(:unique_id => xml["authresponse"]["person"]["uniqueid"],
                       :email => xml["authresponse"]["person"]["email"],
                       :login => "#{xml['authresponse']['person']['firstname']} #{xml["authresponse"]["person"]["lastname"]}")

    r = Role.find(:first, :conditions => {:name => "student"})
    ips = InventoryPool.find(:all, :conditions => {:name => ["AVZ", "ITZ"]})
    ips.each do |ip|
      user.access_rights << AccessRight.new(:role => r, :inventory_pool => ip)
    end
    user.save
    user
  end
  
end