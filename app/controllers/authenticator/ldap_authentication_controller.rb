#require 'net/ldap'
    
class Authenticator::LdapAuthenticationController < Authenticator::AuthenticatorController

  layout 'layouts/backend/general'
        
  def login_form_path
    "/authenticator/ldap/login"
  end
  
  def login
    super
    if request.post?
      user = params[:login][:user]
      password = params[:login][:password]
      if user == "" || password == ""
        flash[:notice] = _("Empty Username and/or Password")
      else
        bind_dn = LDAP_CONFIG[Rails.env]["bind_dn"]
        bind_pwd = LDAP_CONFIG[Rails.env]["bind_pwd"]
        ldap = Net::LDAP.new :host => LDAP_CONFIG[Rails.env]["host"],
                          :port => LDAP_CONFIG[Rails.env]["port"].to_i,
                          :encryption => LDAP_CONFIG[Rails.env]["encryption"].to_sym,
                          :base => LDAP_CONFIG[Rails.env]["base"],
                          :auth=>{:method=>:simple, :username => bind_dn, :password => bind_pwd } 
      
        begin
          if ldap.bind
            users = ldap.search(:base => LDAP_CONFIG[Rails.env]["base"], :filter => Net::LDAP::Filter.eq(LDAP_CONFIG[Rails.env]["search_field"], "#{user}"))

            if users.size == 1
              email = users.first.mail if users.first.mail
              email ||= "#{user}@hkb.bfh.ch"
              bind_dn = users.first.dn
              ldap = Net::LDAP.new :host => LDAP_CONFIG[Rails.env]["host"],
                          :port => LDAP_CONFIG[Rails.env]["port"].to_i,
                          :encryption => LDAP_CONFIG[Rails.env]["encryption"].to_sym,
                          :base => LDAP_CONFIG[Rails.env]["base"],
                          :auth=>{:method=>:simple, :username => bind_dn, :password => password } 
              if ldap.bind
             
                u = User.find_by_login(user)
               
                if not u
                  u = User.create(:login => user, :email => "#{email}")
                  role = Role.find_by_name("customer")
                  InventoryPool.all.each do |ip|
                    u.access_rights.create(:inventory_pool_id => ip, :role => role)
                  end
                end
                u.firstname = users.first["givenname"].to_s 
                u.lastname = users.first["sn"].to_s
                u.phone = users.first["telephonenumber"].to_s unless users.first["telephonenumber"].blank?

                u.save
                self.current_user = u
                redirect_back_or_default("/")
                return true
              else
                flash[:notice] = _("Invalid username/password")
              end
            else
              flash[:notice] = _("User unknown") if users.size == 0
              flash[:notice] = _("Too many users found") if users.size > 0
            end
          else
            flash[:notice] = _("Invalid technical user - contact your leihs admin")
            redirect_to :action => 'login'
          end
        rescue Net::LDAP::LdapError
          flash[:notice] = _("Couldn't connect to LDAP: #{LDAP_CONFIG[:host]}:#{LDAP_CONFIG[:port]}")
        end
      end
    end
  end  
end
