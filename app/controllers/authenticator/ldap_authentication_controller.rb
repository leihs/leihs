class LdapHelper
  attr_reader :unique_id_field
  attr_reader :base_dn
  attr_reader :ldap_config
  attr_reader :host
  attr_reader :port
  attr_reader :search_field

  def initialize
    #@ldap_config = YAML::load_file(Setting::LDAP_CONFIG)
    begin
      @ldap_config = YAML::load_file(File.join(Rails.root, "config", "LDAP.yml"))
    rescue Exception => e
      raise "Could not load LDAP configuration file #{File.join(Rails.root, "config", "LDAP.yml")}: #{e}"
    end
    @base_dn = @ldap_config[Rails.env]["base_dn"]
    @search_field = @ldap_config[Rails.env]["search_field"]
    @host = @ldap_config[Rails.env]["host"]
    @port = @ldap_config[Rails.env]["port"].to_i || 636
    if @ldap_config[Rails.env]["encryption"] == "none"
      @encryption = nil
    else
      @encryption = @ldap_config[Rails.env]["encryption"].to_sym || :simple_tls
    end
    @method = :simple
    @master_bind_dn = @ldap_config[Rails.env]["master_bind_dn"]
    @master_bind_pw = @ldap_config[Rails.env]["master_bind_pw"]
    @unique_id_field = @ldap_config[Rails.env]["unique_id_field"]
    @video_displayname = @ldap_config[Rails.env]["video_displayname"]
    raise "'master_bind_dn' and 'master_bind_pw' must be set in LDAP configuration file" if (@master_bind_dn.blank? or @master_bind_pw.blank?)
    raise "'unique_id_field' in LDAP configuration file must point to an LDAP field that allows unique identification of a user" if @unique_id_field.blank?
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
      logger.error "ERROR: Can't bind to LDAP server #{@host} as user '#{username}'. Wrong bind credentials or encryption parameters?"
      return false
    end
  end
end

class Authenticator::LdapAuthenticationController < Authenticator::AuthenticatorController

  def validate_configuration
    logger = Rails.logger
    begin
      # This thing will complain with an exception if something is wrong about our configuration
      helper = LdapHelper.new
    rescue Exception => e
      flash[:error] = _("You will not be able to log in because this leihs server is not configured correctly. Contact your leihs system administrator.")
      logger.error("ERROR: LDAP is not configured correctly: #{e}")
    end
  end

  def login_form_path
    "/authenticator/ldap/login"
  end

  # @param login [String] The login of the user you want to create
  # @param email [String] The email address of the user you want to create
  def create_user(login, email, firstname, lastname)
    user = User.new(:login => login, :email => "#{email}", :firstname => "#{firstname}", :lastname => "#{lastname}")
    user.authentication_system = AuthenticationSystem.where(:class_name => 'HsluAuthentication').first
    if user.save
      # Assign any default roles you want
      InventoryPool.all.each do |ip|
        user.access_rights.create(:inventory_pool => ip, :role => :customer)
      end
      return user
    else
      logger = Rails.logger
      logger.error "ERROR: Could not create user with login #{login}: #{user.errors.full_messages}"
      return false
    end
  end

  # @param user [User] The (local, database) user whose data you want to update
  # @param user_data [Net::LDAP::Entry] The LDAP entry (it could also just be a hash of hashes and arrays that looks like a Net::LDAP::Entry) of that user
  def update_user(user, user_data)
    logger = Rails.logger
    ldaphelper = LdapHelper.new
    # Make sure to set "user_image_url" in "/manage/settings" in leihs 3.0 for user images to appear, based
    # on the unique ID. Example for the format:
    # http://www.hslu.ch/portrait/{:id}.jpg
    # {:id} will be interpolated with user.unique_id there.
    user.unique_id = user_data[ldaphelper.unique_id_field.to_s].first.to_s
    user.firstname = user_data["givenname"].first.to_s 
    user.lastname = user_data["sn"].first.to_s
    user.phone = user_data["telephonenumber"].first.to_s unless user_data["telephonenumber"].blank?
    user.language = Language.default_language if user.language.blank?

    user.address = user_data["streetaddress"].first.to_s unless user_data["streetaddress"].blank?
    user.city = user_data["l"].first.to_s unless user_data["l"].blank?
    user.country = user_data["c"].first.to_s unless user_data["c"].blank?
    user.zip = user_data["postalcode"].first.to_s unless user_data["postalcode"].blank?

    admin_dn = ldaphelper.ldap_config[Rails.env]["admin_dn"]
    unless admin_dn.blank?
      in_admin_group = false
      begin
        admin_group_filter = Net::LDAP::Filter.eq("member", user_data.dn)
        ldap = ldaphelper.bind
        if (
              ldap.search(:base => admin_dn, :filter => admin_group_filter).count >= 1 or
              (user_data["memberof"] and user_data["memberof"].include?(admin_dn))
           )
          in_admin_group = true
        end
      rescue Exception => e
        logger.error "ERROR: Could not upgrade user #{user.unique_id} to an admin due to exception: #{e}"
      end

      if in_admin_group == true
        if user.access_rights.active.empty? or !user.access_rights.active.collect(&:role).include?(:admin)
          user.access_rights.create(:role => :admin)
        end
      end
    end

  end


  def create_and_login_from_ldap_user(ldap_user, username, password)
    email = ldap_user.mail.first.to_s if ldap_user.mail
    email ||= "#{user}@localhost"
    bind_dn = ldap_user.dn
    firstname = ldap_user.givenname
    lastname = ldap_user.sn
    ldaphelper = LdapHelper.new
    if ldaphelper.bind(bind_dn, password)
      u = User.find_by_unique_id(ldap_user[ldaphelper.unique_id_field.to_s])
      if not u
        u = create_user(username, email, firstname, lastname)
      end

      unless u == false
        update_user(u, ldap_user)
        if u.save
          self.current_user = u
          redirect_back_or_default("/")
        else
          logger.error(u.errors.full_messages.to_s)
          flash[:error] = _("Could not update user '#{username}' with new LDAP information. Contact your leihs system administrator.")
        end
      else
        flash[:error] = _("Could not create new user for '#{username}' from LDAP source. Contact your leihs system administrator.")
      end
    else
      flash[:error] = _("Invalid username/password")
    end
  end

  def login
    super
    @preferred_language = Language.preferred(request.env["HTTP_ACCEPT_LANGUAGE"])

    if request.post?
      username = params[:login][:username]
      password = params[:login][:password]
      if username == "" || password == ""
        flash[:notice] = _("Empty Username and/or Password")
      else
        ldaphelper = LdapHelper.new
        begin
          ldap = ldaphelper.bind

          if ldap
            users = ldap.search(:base => ldaphelper.base_dn, :filter => Net::LDAP::Filter.eq(ldaphelper.search_field, "#{username}"))

            if users.size == 1
              create_and_login_from_ldap_user(users.first, username, password)
            else
              flash[:error] = _("User unknown") if users.size == 0
              flash[:error] = _("Too many users found") if users.size > 0
            end
          else
            flash[:error] = _("Invalid technical user - contact your leihs admin")
          end
        rescue Net::LDAP::LdapError
          flash[:error] = _("Couldn't connect to LDAP server: #{ldaphelper.host}:#{ldaphelper.port}")
        end
      end
    else
      validate_configuration
    end
  end

end
