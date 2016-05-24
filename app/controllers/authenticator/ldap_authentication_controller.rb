class LdapHelper
  attr_reader :unique_id_field
  attr_reader :base_dn
  attr_reader :ldap_config
  attr_reader :host
  attr_reader :port
  attr_reader :search_field
  #set this to true if you want to enable looking inside nested groups for user membership of 
  #the groups mentioned below.
  #example: User is member of group1, group1 is member of group2, admin_dn is set to group2
  attr_reader :look_in_nested_groups_for_membership
  #group of normal users with permission to log into Leihs. Optional. Can be left blank.
  attr_reader :normal_users_dn
  #group of leihs admins. users may be member of normal_users_dn at the same time
  attr_reader :admin_dn
  
  #RFC2254 magic number. If used in a filter, allows looking inside nested LDAP groups for users
  def LDAP_MATCHING_RULE_IN_CHAIN
    return "1.2.840.113556.1.4.1941"
  end
  
  #RFC 2251, Section 4.5.1. Special object identifier.
  #If passed as an attribute of an LDAP search, only distinguished names are returned
  def LDAP_return_only_DN
    return "1.1"
  end

  def initialize
    begin
      if (defined?(Setting::LDAP_CONFIG) and not Setting::LDAP_CONFIG.blank?)
        @ldap_config = YAML::load_file(Setting::LDAP_CONFIG)
      else
        @ldap_config = YAML::load_file(File.join(Rails.root, 'config', 'LDAP.yml'))
      end
    rescue Exception => e
      raise 'Could not load LDAP configuration file ' \
            "#{File.join(Rails.root, 'config', 'LDAP.yml')}: #{e}"
    end
    @base_dn = @ldap_config[Rails.env]['base_dn']
    @admin_dn = @ldap_config[Rails.env]['admin_dn']
    @look_in_nested_groups_for_membership = @ldap_config[Rails.env]['look_in_nested_groups_for_membership'] == "true"
    @normal_users_dn = @ldap_config[Rails.env]['normal_users_dn']
    @search_field = @ldap_config[Rails.env]['search_field']
    @host = @ldap_config[Rails.env]['host']
    @port = @ldap_config[Rails.env]['port'].to_i || 636
    if @ldap_config[Rails.env]['encryption'] == 'none'
      @encryption = nil
    else
      @encryption = @ldap_config[Rails.env]['encryption'].to_sym || :simple_tls
    end
    @method = :simple
    @master_bind_dn = @ldap_config[Rails.env]['master_bind_dn']
    @master_bind_pw = @ldap_config[Rails.env]['master_bind_pw']
    @unique_id_field = @ldap_config[Rails.env]['unique_id_field']
    @video_displayname = @ldap_config[Rails.env]['video_displayname']
    if (@master_bind_dn.blank? or @master_bind_pw.blank?)
      raise "'master_bind_dn' and 'master_bind_pw' must be set in " \
            'LDAP configuration file'
    end
    if @unique_id_field.blank?
      raise "'unique_id_field' in LDAP configuration file must point to " \
            'an LDAP field that allows unique identification of a user'
    end
  end

  def bind(username = @master_bind_dn, password = @master_bind_pw)
    ldap = Net::LDAP.new host: @host,
                         port: @port,
                         encryption: @encryption,
                         base: @base_dn,
                         auth: {
                           method: @method,
                           username: username,
                           password: password
                         }

    if ldap.bind
      return ldap
    else
      logger = Rails.logger
      logger.error "ERROR: Can't bind to LDAP server #{@host} " \
                   "as user '#{username}'. " \
                   'Wrong bind credentials or encryption parameters?'
      return false
    end
  end
end

class Authenticator::LdapAuthenticationController \
  < Authenticator::AuthenticatorController

  def validate_configuration
    logger = Rails.logger
    begin
      # This thing will complain with an exception if something
      # is wrong about our configuration
      _helper = LdapHelper.new
    rescue Exception => e
      flash[:error] = \
        _('You will not be able to log in because this leihs server ' \
          'is not configured correctly. Contact your leihs system administrator.')
      logger.error("ERROR: LDAP is not configured correctly: #{e}")
    end
  end

  def login_form_path
    '/authenticator/ldap/login'
  end

  # @param login [String] The login of the user you want to create
  # @param email [String] The email address of the user you want to create
  def create_user(login, email, firstname, lastname)
    user = User.new(login: login,
                    email: "#{email}",
                    firstname: "#{firstname}",
                    lastname: "#{lastname}")
    user.authentication_system = \
      AuthenticationSystem.where(class_name: 'LdapAuthentication').first
    if user.save
      return user
    else
      logger = Rails.logger
      logger.error "ERROR: Could not create user with login #{login}: " \
                   "#{user.errors.full_messages}"
      return false
    end
  end

  # @param user [User] The (local, database) user whose data you want to update
  # @param user_data [Net::LDAP::Entry] The LDAP entry (it could also just be
  # a hash of hashes and arrays that looks like a Net::LDAP::Entry) of that user
  def update_user(user, user_data)
    logger = Rails.logger
    ldaphelper = LdapHelper.new
    # Make sure to set "user_image_url" in "/admin/settings" in leihs 3.0
    # for user images to appear, based on the unique ID. Example for the format:
    # http://www.hslu.ch/portrait/{:id}.jpg
    # {:id} will be interpolated with user.unique_id there.
    user.unique_id = user_data[ldaphelper.unique_id_field.to_s].first.to_s
    user.firstname = user_data['givenname'].first.to_s
    user.lastname = user_data['sn'].first.to_s
    unless user_data['telephonenumber'].blank?
      user.phone = user_data['telephonenumber'].first.to_s
    end
    user.language = Language.default_language if user.language.blank?

    unless user_data['streetaddress'].blank?
      user.address = user_data['streetaddress'].first.to_s
    end
    user.city = user_data['l'].first.to_s unless user_data['l'].blank?
    user.country = user_data['c'].first.to_s unless user_data['c'].blank?
    unless user_data['postalcode'].blank?
      user.zip = user_data['postalcode'].first.to_s
    end

    admin_dn = ldaphelper.admin_dn
    unless admin_dn.blank?
      in_admin_group = false
      begin
        in_admin_group = user_is_member_of_ldap_group(user_data, admin_dn)
        logger.error ("value of in_admin_group: #{in_admin_group}")
        if in_admin_group == true
          logger.error ('Logging in as member of admin group.')
          flash[:notice] = _('Logging in as member of admin group.')
          if user.access_rights.active.empty? \
            or !user.access_rights.active.collect(&:role).include?(:admin)
            user.access_rights.create(role: :admin)
          end
        end
      rescue Exception => e
        logger.error "ERROR: Could not upgrade user #{user.unique_id} " \
                     "to an admin due to exception: #{e}"
      end


    end
  end
  
  # @param user_data [Net::LDAP::Entry] The LDAP entry (it could also just be
  # a hash of hashes and arrays that looks like a Net::LDAP::Entry) of that user
  # @param group_dn [String] The distinguished name of the LDAP group you want to check for.
  # Is the user is a member of this group?
  # @return [Boolean] TRUE if user is a member of the group. FALSE if user is NOT a member of the group OR exception occured
  def user_is_member_of_ldap_group(user_data, group_dn)
    logger = Rails.logger
    ldaphelper = LdapHelper.new
    begin
      ldap = ldaphelper.bind
      
      if ldaphelper.look_in_nested_groups_for_membership
        logger.debug("Nested LDAP group membership checking is enabled.")
        #construct a filter from string, according to RFC2254 syntax. Returns Filter object, needed for search 
        nested_group_filter = Net::LDAP::Filter.construct("member:#{ldaphelper.LDAP_MATCHING_RULE_IN_CHAIN}:=#{user_data.dn}")
      
        #Example code for search of nested group memebership. stolen from cpan NET::LDAP
        #See also Microsoft documentation at
        #https://msdn.microsoft.com/en-us/library/aa746475%28v=vs.85%29.aspx
        #2016.05.24, DerBachmannRocker
        #$mesg = $ldap->search( base   => 'dc=your,dc=ads,dc=domain',
        #                   filter => '(member:1.2.840.113556.1.4.1941:=cn=TestUser,ou=Users,dc=your,dc=ads,dc=domain)',
        #                   attrs  => [ '1.1' ]
        #                 );
        logger.debug("Constructed nested_group_filter: #{nested_group_filter}")
        #result nested_group_filter value: (member:1.2.840.113556.1.4.1941:=CN=studiAnon,OU=Static,OU=HumanUsers,OU=mht_Users,DC=mhtnet,DC=mh-trossingen,DC=de)
        allNestedMemberShipGroups = ldap.search(base: group_dn, filter: nested_group_filter, attrs: ldaphelper.LDAP_return_only_DN)
        logger.debug("allNestedMemberShipGroups. Count: #{allNestedMemberShipGroups.count}")
        for item in allNestedMemberShipGroups.each
          logger.debug(item.dn)
        end
        
        #we have found the group membership we are looking for, if the search result was not empty
        if allNestedMemberShipGroups.count >= 1
          true
        end
      end  

      #old method of search. included, as to minimize side-effects of above method I did not think of
      simple_group_filter = Net::LDAP::Filter.eq('member', user_data.dn)
      
      #logger.debug("Ldap value: #{ldap}")
      #logger.debug("simple_group_filter value: #{simple_group_filter}")
      #result: simple_group_filter value: (member=CN=David Franzkoch,OU=Verwaltung,OU=Static,OU=HumanUsers,OU=mht_Users,DC=mhtnet,DC=mh-trossingen,DC=de)
      #logger.debug("user_data memberOf: #{user_data['memberof']}")
      #logger.debug("Ldap search: #{ldap.search(base: group_dn, filter: simple_group_filter)}")
      
      if (ldap.search(base: group_dn, filter: simple_group_filter).count >= 1 or
            (user_data['memberof'] and user_data['memberof'].include?(group_dn)))
        logger.debug("User logging in is a member of group #{group_dn}:" \
                        '#{user_data.dn}')
        true
      else
        logger.debug ("User logging in is NOT a member of group #{group_dn}:" \
                        '#{user_data.dn}')
        false
      end
    rescue Exception => e
      logger.error("ERROR: Could not query LDAP group membership of user '#{user_data.dn}' for group '#{group_dn}' " \
                   "Exception: #{e}")
      false
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
      unless u
        u = create_user(username, email, firstname, lastname)
      end

      unless u == false
        update_user(u, ldap_user)
        if u.save
          self.current_user = u
          redirect_back_or_default('/')
        else
          logger.error(u.errors.full_messages.to_s)
          flash[:error] = \
            _("Could not update user '#{username}' with new LDAP information. " \
              'Contact your leihs system administrator.')
        end
      else
        flash[:error] = \
          _("Could not create new user for '#{username}' from LDAP source. " \
            'Contact your leihs system administrator.')
      end
    else
      flash[:error] = _('Invalid username/password')
    end
  end

  def login
    super
    @preferred_language = Language.preferred(request.env['HTTP_ACCEPT_LANGUAGE'])

    if request.post?
      username = params[:login][:user]
      password = params[:login][:password]
      if username == '' || password == ''
        flash[:notice] = _('Empty Username and/or Password')
      else
        ldaphelper = LdapHelper.new
        begin
          ldap = ldaphelper.bind

          if ldap
            users = \
              ldap.search \
                base: ldaphelper.base_dn,
                filter: \
                  Net::LDAP::Filter.eq(ldaphelper.search_field, "#{username}")

            # TODO: remove 3rd level of block nesting
            # rubocop:disable Metrics/BlockNesting
            if users.size == 1
              #TODO: add check if user is member of AD group that allows access to leihs
              #admin group and/or users group
              create_and_login_from_ldap_user(users.first, username, password)
            else
              flash[:error] = _('User unknown') if users.size == 0
              flash[:error] = _('Too many users found') if users.size > 0
            end
            # rubocop:enable Metrics/BlockNesting
          else
            flash[:error] = _('Invalid technical user - contact your leihs admin')
          end
        rescue Net::LDAP::LdapError
          flash[:error] = _("Couldn't connect to LDAP server: " \
                            "#{ldaphelper.host}:#{ldaphelper.port}")
        end
      end
    else
      validate_configuration
    end
  end

end
