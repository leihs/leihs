#require 'net/ldap'

class LdapHelper

  # Needed later on in the auth controller
  attr_reader :unique_id_field
  # Based on what string in the field displayName should the user be assigned to the group "Video"?
  attr_reader :video_displayname
  attr_reader :base_dn

  def initialize
    @base_dn = LDAP_CONFIG[Rails.env]["base_dn"]
    @search_field = LDAP_CONFIG[Rails.env]["search_field"]
    @host = LDAP_CONFIG[Rails.env]["host"]
    @port = LDAP_CONFIG[Rails.env]["port"].to_i || 636
    @encryption = LDAP_CONFIG[Rails.env]["encryption"].to_sym || :simple_tls
    @method = :simple
    @master_bind_dn = LDAP_CONFIG[Rails.env]["master_bind_dn"]
    @master_bind_pw = LDAP_CONFIG[Rails.env]["master_bind_pw"]
    @unique_id_field = LDAP_CONFIG[Rails.env]["unique_id_field"]
    @video_displayname = LDAP_CONFIG[Rails.env]["video_displayname"]
    raise "'master_bind_dn' and 'master_bind_pw' must be set in LDAP configuration file" if (@master_bind_dn.blank? or @master_bind_pw.blank?)
    raise "'unique_id_field' in LDAP configuration file must point to an LDAP field that allows unique identification of a user" if @unique_id_field.blank?
    raise "'video_displayname' in LDAP configuration file must be present and must be a string" if @video_displayname.blank?
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
      logger = Rails.logger
      logger.error "Can't bind to LDAP server #{@host} as user '#{username}'. Wrong bind credentials or encryption parameters?"
      return false
    end
  end
end


class Authenticator::HsluAuthenticationController < Authenticator::AuthenticatorController

  def login_form_path
    "/authenticator/hslu/login"
  end


  # @param login [String] The login of the user you want to create
  # @param email [String] The email address of the user you want to create
  def create_user(login, email)
    user = User.new(:login => login, :email => "#{email}")
    user.authentication_system = AuthenticationSystem.where(:class_name => 'HsluAuthentication').first
    if user.save
      # Assign any default roles you want
      role = Role.where(:name => "customer").first
      InventoryPool.all.each do |ip|
        user.access_rights.create(:inventory_pool => ip, :role => role)
      end
      return user
    else
      logger = Rails.logger
      logger.error "Could not create user with login #{login}: #{user.errors.full_messages}"
      return false
    end
  end

  # @param user [User] The (local, database) user whose data you want to update
  # @param user_data [Net::LDAP::Entry] The LDAP entry (it could also just be a hash of hashes and arrays that looks like a Net::LDAP::Entry) of that user
  def update_user(user, user_data)
    logger = Rails.logger
    ldaphelper = LdapHelper.new
    # Make sure to set USER_IMAGE_URL in application.rb in leihs 3.0 for user images to appear, based
    # on the unique ID. Example for the format in application.rb:
    # http://www.hslu.ch/portrait/{:id}.jpg
    # {:id} will be interpolated with user.unique_id there.
    user.unique_id = user_data[ldaphelper.unique_id_field.to_s].first.to_s
    user.firstname = user_data["givenname"].first.to_s 
    user.lastname = user_data["sn"].first.to_s
    user.phone = user_data["telephonenumber"].first.to_s unless user_data["telephonenumber"].blank?
    # If the user's unique_id is numeric, add an "L" to the front and copy it to the badge_id
    # If it's not numeric, just copy it straight to the badge_id
    if (user.unique_id =~ /^(\d+)$/).nil?
      user.badge_id = user.unique_id
    else
      user.badge_id = "L" + user.unique_id
    end
    user.language = Language.default_language if user.language.blank?

    user.address = user_data["streetaddress"].first.to_s
    user.city = user_data["l"].first.to_s
    user.country = user_data["c"].first.to_s
    user.zip = user_data["postalcode"].first.to_s

    admin_dn = LDAP_CONFIG[Rails.env]["admin_dn"]
    unless admin_dn.blank?
      if user_data["memberof"].include?(admin_dn)
        admin_role = Role.where(:name => "admin").first
        if user.access_rights.empty? or !user.access_rights.collect(&:role).include?(admin_role)
          user.access_rights.create(:role => admin_role)
        end
      end
    end

    # If the displayName contains whatever string is configured in video_displayname in LDAP.yml,
    # the user is assigned to the group "Video"
    unless user_data["displayName"].first.scan(ldaphelper.video_displayname.to_s).empty?
      video_group = Group.where(:name => 'Video').first
      unless video_group.nil?
        user.groups << video_group unless user.groups.include?(video_group)
      end
    end
  end
  
  def login
    super
    @preferred_language = Language.preferred(request.env["HTTP_ACCEPT_LANGUAGE"])

    if request.post?
      user = params[:login][:username]
      password = params[:login][:password]
      if user == "" || password == ""
        flash[:notice] = _("Empty Username and/or Password")
      else
        ldaphelper = LdapHelper.new
        begin
          ldap = ldaphelper.bind

          if ldap
            users = ldap.search(:base => ldaphelper.base_dn, :filter => Net::LDAP::Filter.eq(LDAP_CONFIG[Rails.env]["search_field"], "#{user}"))

            if users.size == 1
              ldap_user = users.first
              email = ldap_user.mail.first.to_s if ldap_user.mail
              email ||= "#{user}@hslu.ch"
              bind_dn = users.first.dn
              ldaphelper = LdapHelper.new
              if ldaphelper.bind(bind_dn, password)
                u = User.find_by_unique_id(ldap_user[ldaphelper.unique_id_field.to_s])
                if not u
                  u = create_user(user, email)
                end

                if not u == false
                  update_user(u, users.first)
                  if u.save
                    self.current_user = u
                    redirect_back_or_default("/")
                  else
                    logger.error(u.errors.full_messages.to_s)
                    flash[:notice] = _("Could not update user '#{user}' with new LDAP information. Contact your leihs system administrator.")
                  end
                else
                  flash[:notice] = _("Could not create new user for '#{user}' from LDAP source. Contact your leihs system administrator.")
                end
              else flash[:notice] = _("Invalid username/password")
              end
            else
              flash[:notice] = _("User unknown") if users.size == 0
              flash[:notice] = _("Too many users found") if users.size > 0
            end
          else
            flash[:notice] = _("Invalid technical user - contact your leihs admin")
          end
        rescue Net::LDAP::LdapError
          flash[:notice] = _("Couldn't connect to LDAP: #{LDAP_CONFIG[:host]}:#{LDAP_CONFIG[:port]}")
        end
      end
    end
  end
end
