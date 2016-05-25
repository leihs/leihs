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
    #implicit cast from string to trueclass. handled by YAML
    @look_in_nested_groups_for_membership = @ldap_config[Rails.env]['look_in_nested_groups_for_membership']
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

    logger.error ("admin_dn value: #{ldaphelper.admin_dn}")
    admin_dn = ldaphelper.admin_dn
    unless admin_dn.blank?
      in_admin_group = false
      begin
        in_admin_group = user_is_member_of_ldap_group(user_data, admin_dn)
        #logger.error ("value of in_admin_group: #{in_admin_group}")
        if in_admin_group == true
          logger.info ("User logging in is member of LDAP admin group: #{user_data['cn']}")
          flash[:notice] = _('You are a member of the LDAP admin group.')
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
      
      #New method of searching for group membership
      #Only one simple search, using special LDAP syntax
      #I only tested this with Active Directory, Server 2012
      #SHOULD work for other LDAP flavours too, because the magic number the search
      #uses is defined in RFC2254 which applies not only to Microsoft
      #DerBachmannRocker 2016.5.25
      if ldaphelper.look_in_nested_groups_for_membership == true
        logger.debug("Nested LDAP group membership checking is enabled.")
        #construct a filter from string, according to RFC2254 syntax. Returns Filter object, needed for search 
        nested_group_filter = Net::LDAP::Filter.construct("member:#{ldaphelper.LDAP_MATCHING_RULE_IN_CHAIN}:=#{user_data.dn}")
      
        #Example code for search of nested group memebership. stolen from cpan NET::LDAP
        #See also Microsoft documentation at
        #https://msdn.microsoft.com/en-us/library/aa746475%28v=vs.85%29.aspx
        #  #$mesg = $ldap->search( base   => 'dc=your,dc=ads,dc=domain',
        #                   filter => '(member:1.2.840.113556.1.4.1941:=cn=TestUser,ou=Users,dc=your,dc=ads,dc=domain)',
        #                   attrs  => [ '1.1' ]
        #                 );
        
        #logger.debug("Constructed nested_group_filter: #{nested_group_filter}")
        #result nested_group_filter value: (member:1.2.840.113556.1.4.1941:=CN=leihstest,OU=Static,OU=HumanUsers,OU=mht_Users,DC=mhtnet,DC=mh-trossingen,DC=de)
  
        #limit scope of search. look only inside group_dn LDAP tree
        #search for all (nested and simple) group memberships of the user
        #use LDAP_return_only_DN, because we do not want other types of results to be returned
        #(possibly not needed, but included to match example above)
        nestedGroupSearchResult = ldap.search(base: group_dn, filter: nested_group_filter, attrs: ldaphelper.LDAP_return_only_DN)

        unless nestedGroupSearchResult
          logger.error("LDAP search for group returned NIL result, which should not happen. Probably the following group does not exist in LDAP. Check your LDAP config file." \
                      "#{group_dn}")
          flash[:error] = ('There is a problem with LDAP group configuration. Please contact your LEIHS administrator.')
        else
          #logger.debug("nestedGroupSearchResult. Count: #{nestedGroupSearchResult.count}")
          #for item in nestedGroupSearchResult.each
          #  logger.debug(item.dn)
          #end
          
          #we have found the group membership we are looking for, if the search result was not empty
          #this should normally be 1, but can be higher if the user is member of multiple group-nesting levels
          if nestedGroupSearchResult.count >= 1
            logger.debug("nestedSearch: User logging in is a member of group #{group_dn}:" \
                          '#{user_data.dn}')
            return true
          end
        end
      end  

      #old method of search. ignoring nested groups
      #This is executed if the new method returns no result/is disabled
      #I kept this method of search in, because I can only test with Active Directory and I do not want to break
      #login for different LDAP installations (Samba, etc.). Maybe they do not respond to the magic number search filter of the new method?
      #Code may be removed if tests on other LDAP installations are successful
      #DerBachmannRocker 2016.5.25
      simple_group_filter = Net::LDAP::Filter.eq('member', user_data.dn)
      simpleGroupSearchResult = ldap.search(base: group_dn, filter: simple_group_filter)

      #check for simpleGroupSearchResult == NIL. Exception might occur otherwise -> NIL.count
      if (simpleGroupSearchResult and simpleGroupSearchResult.count >= 1 or
            (user_data['memberof'] and user_data['memberof'].include?(group_dn)))
        logger.debug("User logging in is a member of group #{group_dn}:" \
                        '#{user_data.dn}')
        return true
      else
        logger.debug ("User logging in is NOT a member of group #{group_dn}:" \
                        '#{user_data.dn}')
        return false
      end
    rescue Exception => e
      logger.error("ERROR: Could not query LDAP group membership of user '#{user_data.dn}' for group '#{group_dn}' " \
                   "Exception: #{e}")
      flash[:error] = ('Unexpected error while querying for LDAP group membership. Please contact your LEIHS administrator.')
      return false
    end
  end

  def create_and_login_from_ldap_user(ldap_user, username, password)
    logger = Rails.logger
    
    begin  
      #check for mandatory user fields

      #email address is mandatory for account creation
      #Made decision to show error instead of creating user with dummy mail address
      #This did not work before anyways. Leihs crashed if LDAP user logged on with no email set in LDAP
      #so below code is *no new behaviour* and admins needed to set the email correctly anyways.
      #Probably better to show error if undefined and quit than to blindly guess
      #Line that caused crash and ELSE path:
      #email = ldap_user.mail.first.to_s if ldap_user.mail
      #email ||= "#{user}@localhost"
      #Replaced by:
      if !(ldap_user['mail'].blank?) and (ldap_user.mail.first.to_s != '')
        #warning: be careful to leave check for blank email in first position of the AND operator.
        #Active directory does not return the attribute "mail" at all when left blank.
        #exception in this case, when accessing ldap_user.mail (because NIL), when not catched by the AND
        email = ldap_user.mail.first.to_s
      else
        logger.error("LDAP user with blank eMail attribute attempted login: #{username}")
        flash[:error] = \
          _("Unable to login. Your user account has no eMail address set. Please contact your LEIHS administrator.")
        return
      end
      
      if !(ldap_user['givenname'].blank?) and (ldap_user.givenname.to_s != '')
        firstname = ldap_user.givenname.to_s
      else
        logger.error("LDAP user with blank givenname (first name) attribute attempted login: #{username}")
        flash[:error] = \
          _("Unable to login. Your user account has no first name set. Please contact your LEIHS administrator.")
        return
      end
      
      if !(ldap_user['sn'].blank?) and (ldap_user.sn.to_s != '')
        lastname = ldap_user.sn.to_s
      else
        logger.error("LDAP user with blank sn (family name) attribute attempted login: #{username}")
        flash[:error] = \
        _("Unable to login. Your user account has no family name set. Please contact your LEIHS administrator.")
        return
      end
      
      #should be uncritical. every LDAP::Entry object should have this set
      bind_dn = ldap_user.dn
    rescue Exception => e
      logger.error("Unexpected exception while checking required LDAP user attributes for user #{username}:" \
                  "Exception: #{e}")
      flash[:error] = \
      _("Unable to login. Unexpected error. Please contact your LEIHS administrator.")
    end

    #checks passed. create user / log in
    begin
      ldaphelper = LdapHelper.new

      if not ldaphelper.bind(bind_dn, password)
        flash[:error] = _('Invalid username/password')
        return
      end 
      
      u = User.find_by_unique_id(ldap_user[ldaphelper.unique_id_field.to_s])
      unless u
        logger.info ("User was not found in local DB. Creating user with data from LDAP: #{username}")
        u = create_user(username, email, firstname, lastname)
        unless u
          logger.error ("Could not create new user from LDAP (function create_user returned nothing)")
          flash[:error] = \
           _("Could not create new user for '#{username}' from LDAP source. " \
          'Contact your leihs system administrator.')
          return
        end
      end

      update_user(u, ldap_user)
      if u.save
        self.current_user = u
        logger.debug("Login successful for user #{username}.")
        redirect_back_or_default('/')
      else
        logger.error("Could not update user '#{username}' with new LDAP information.")
        logger.error(u.errors.full_messages.to_s)
        flash[:error] = \
          _("Could not update user '#{username}' with new LDAP information. " \
            'Contact your leihs system administrator.')
      end
    rescue Exception => e
      logger.error("Unexpected exception in create_and_login_from_ldap_user:" \
                  "Exception: #{e}")
      flash[:error] = \
      _("Unable to login. Unexpected error. Please contact your LEIHS administrator.")
    end
  end

  def login
    super
    @preferred_language = Language.preferred(request.env['HTTP_ACCEPT_LANGUAGE'])

    logger = Rails.logger

    if request.post?
      username = params[:login][:user]
      password = params[:login][:password]
      if username == '' || password == ''
        flash[:notice] = _('Empty Username and/or Password')
      else
        ldaphelper = LdapHelper.new
        logger.debug("LDAP user trying to log in: #{username}")
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
              if users.size > 0
                 flash[:error] = _('Too many users found')
                 logger.error("Too many users matching given username. This should not happen. User login: #{username}"
              end
            end
            # rubocop:enable Metrics/BlockNesting
          else
            flash[:error] = _('Unable to connect to LDAP - contact your leihs admin!')
            logger.error("Unable to bind to LDAP! ldaphelper.bind returned NIL. Check LDAP config file. (master_bind_dn, master_bind_pw, etc.)")
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
