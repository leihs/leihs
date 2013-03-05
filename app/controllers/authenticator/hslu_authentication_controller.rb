#require 'net/ldap'
require 'net/ldap'

class LdapHelper
  def initialize
    @base_dn = LDAP_CONFIG[Rails.env]["base_dn"]
    @search_field = LDAP_CONFIG[Rails.env]["search_field"]
    @host = LDAP_CONFIG[Rails.env]["host"]
    @port = LDAP_CONFIG[Rails.env]["port"].to_i || 636
    @encryption = :LDAP_CONFIG[Rails.env]["encryption"].to_sym || :simple_tls
    @method = :simple
    @master_bind_dn = LDAP_CONFIG[Rails.env]["master_bind_dn"]
    @master_bind_pw = LDAP_CONFIG[Rails.env]["master_bind_pw"]
    raise "'master_bind_dn' and 'master_bind_pw' must be set in LDAP configuration file" if (@master_bind_dn.blank? or @master_bind_pw.blank?)
  end

  def bind(username = @master_bind_dn, password = @master_bind_pw)
    ldap = Net::LDAP.new :host => @host,
    :port => @port, 
    :encryption => @encryption,
    :base => @base_dn,
    :auth => {
      :method=> @method,
      :username => username,
      :password => password 
    }
    if ldap.bind
      return ldap
    else
      raise "Can't bind to LDAP server #{@host}. Wrong bind credentials or encryption parameters?"
      return false
    end
  end
end


class Authenticator::LdapAuthenticationController < Authenticator::AuthenticatorController

  layout 'layouts/backend/general'
        
  def login_form_path
    "/authenticator/ldap/login"
  end
  
  def login
    if request.post?
      user = params[:login][:user]
      password = params[:login][:password]
      if user == "" || password == ""
        flash[:notice] = _("Empty Username and/or Password")
      else
        ldap = LdapHelper.new
        begin
          if ldap.bind
            users = ldap.search(:base => LDAP_CONFIG[Rails.env]["base"], :filter => Net::LDAP::Filter.eq(LDAP_CONFIG[Rails.env]["search_field"], "#{user}"))

            if users.size == 1
              email = users.first.mail if users.first.mail
              email ||= "#{user}@hslu.ch"
              bind_dn = users.first.dn
              userldap = LdapHelper.new 
              if userldap.bind(bind_dn, password)
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
