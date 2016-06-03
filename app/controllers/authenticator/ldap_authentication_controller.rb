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
  #Active Directory handles Primary Group membership differently than other groups
  #The primary group of a user will *not* appear in its memberOf attribute and is invisible to the
  #look_in_nested_groups_for_membership search method.
  #If you want to use the primary group for anything, set this to 'true'
  attr_reader :look_for_primary_group_membership_ActiveDirectory
  #group of normal users with permission to log into leihs. Optional. Can be left blank.
  attr_reader :normal_users_dn
  #group of leihs admins. users may be member of normal_users_dn at the same time
  attr_reader :admin_dn
  #if no errors are raised during reading of LDAP config file, this is set to true. Otherwise false.
  attr_reader :configIsOk
  
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
    @configIsOk = false
    begin
      begin
        if (defined?(Setting::LDAP_CONFIG) and not Setting::LDAP_CONFIG.blank?)
          configFilePath = Setting::LDAP_CONFIG
        else
          configFilePath = File.join(Rails.root, 'config', 'LDAP.yml')
        end
        @ldap_config = YAML::load_file(configFilePath)
      rescue Exception => e
        raise 'Could not load LDAP configuration file ' \
              "#{configFilePath}: #{e}"
      end
      
      #custom log file. should be read first to enable logging of errors with other LDAPconfig flags
      #may be left blank in config
      if (defined?(@ldap_config[Rails.env]['log_file']) and (not @ldap_config[Rails.env]['log_file'].blank?))
        #config line log_file should be relative path to a file (does not have to exist yet)
        #log/ldap_server.log
        if File.writable?(Rails.root.join(@ldap_config[Rails.env]['log_file']))
          @@log_file = Rails.root.join(@ldap_config[Rails.env]['log_file'])
        else
          @@log_file = ''
          raise "The LDAP logfile specified can not be opened for write access. Configured file path: #{@log_file}"
        end
        
        #serverity of custom log is only relevant if logfile path was configured
        begin
          @@log_level = Logger.const_get(@ldap_config[Rails.env]['log_level'])
        rescue Exception => e
          #see Logger::Severity
          raise "LDAP log_level needs to be set to any of the following values: DEBUG, ERROR, FATAL, INFO, UNKNOWN, WARN"
          @@log_level = Logger::DEBUG
        end
      else
        #custom logfile disabled. see get_logger()
        @@log_file = ''
      end      
      
      @base_dn = @ldap_config[Rails.env]['base_dn']
      @admin_dn = @ldap_config[Rails.env]['admin_dn']
      @look_in_nested_groups_for_membership = @ldap_config[Rails.env]['look_in_nested_groups_for_membership'] == 'true'
      @look_for_primary_group_membership_ActiveDirectory = @ldap_config[Rails.env]['look_for_primary_group_membership_ActiveDirectory'] == 'true'
  
      if (defined?(@ldap_config[Rails.env]['normal_users_dn']) and (not @ldap_config[Rails.env]['normal_users_dn'].blank?))
        @normal_users_dn = @ldap_config[Rails.env]['normal_users_dn']
      else
        @normal_users_dn = ''
      end
      @search_field = @ldap_config[Rails.env]['search_field']
      @host = @ldap_config[Rails.env]['host']
      @port = @ldap_config[Rails.env]['port'].to_i || 636
      
      if @ldap_config[Rails.env]['encryption'] == 'none'
        @encryption = nil
      elsif @ldap_config[Rails.env]['encryption'] == 'simple_tls'
        @encryption = :simple_tls
      else
        raise "LDAP encryption needs to be set to one of the following values: none, simple_tls"
      end
      
      #LDAP bind method
      @method = :simple
      
      @master_bind_dn = @ldap_config[Rails.env]['master_bind_dn']
      @master_bind_pw = @ldap_config[Rails.env]['master_bind_pw']
      @unique_id_field = @ldap_config[Rails.env]['unique_id_field']
      @video_displayname = @ldap_config[Rails.env]['video_displayname']
      if (@master_bind_dn.blank? or @master_bind_pw.blank?)
        raise "'master_bind_dn' and 'master_bind_pw' may not be left blank!"
      end
      if @unique_id_field.blank?
        raise "'unique_id_field' in LDAP configuration file must point to " \
              'an LDAP field that allows unique identification of a user'
      end
      
      #check the master_bind credentials
      if self.bind() == false
        raise "Could not bind to LDAP using configured master_bind credentials."
      end
      
      @configIsOk = true
    rescue Exception => e
      @configIsOk = false
      logger = LdapHelper::get_logger()
      logger.error("ERROR: LDAP is not configured correctly: #{e}" \
      "Please check LDAP config file: #{configFilePath}" )
    end
  end

  # Returns an object of class Logger. Either the default Rails default log
  # or, if configured, the LDAP logger (special logfile)
  # This is defined as static method to not complicate things while trying to log
  # errors during initialization of an instance
  # @return [Logger] Object of class Logger
  def self.get_logger()
    begin
      unless @@log_file.blank?
        mylogger = Logger.new(File.new(@@log_file,"a+"))
        mylogger.level = @@log_level
        return mylogger
      else
        return Rails.logger
      end
    rescue Exception => e
      Rails.logger.error("Unexpected exception in get_logger. Returning Rails default log." \
                   "Exception: #{e}" \
                   "#{e.backtrace.slice(1,500)}...")
      return Rails.logger 
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
      logger = self.get_logger()
      logger.error "ERROR: Can't bind to LDAP server #{@host} " \
                   "as user '#{username}'. " \
                   'Wrong bind credentials or encryption parameters?' \
                   "Returned error code: #{ldap.get_operation_result.code}" \
                   "Error Message: #{ldap.get_operation_result.message}"
      return false
    end
  end
end

class Authenticator::LdapAuthenticationController \
  < Authenticator::AuthenticatorController

  def validate_configuration
    #this method will display the result of ldap config file validation to the user
    
    #initialize() of class LdapHelper will handle
    #exceptions, checks and log entries by itself. This is much safer, in case LdapHelper is instantiated 
    #outside a begin / rescue block

    _helper = LdapHelper.new
    unless _helper.configIsOk == true
      flash[:error] = \
       _('You will not be able to log in because this leihs server ' \
          'is not configured correctly. Contact your leihs system administrator.')
    end
  end

  def login_form_path
    '/authenticator/ldap/login'
  end

  # @param login [String] The login of the user you want to create
  # @param email [String] The email address of the user you want to create
  def create_user(login, email, firstname, lastname)
    ldaphelper = LdapHelper.new
    logger = LdapHelper::get_logger()
    unless ldaphelper.configIsOk == true
      return false
    end
    
    user = User.new(login: login,
                    email: "#{email}",
                    firstname: "#{firstname}",
                    lastname: "#{lastname}")
    user.authentication_system = \
      AuthenticationSystem.where(class_name: 'LdapAuthentication').first
    if user.save
      return user
    else
      logger.error "ERROR: Could not create user with login #{login}: " \
                   "#{user.errors.full_messages}"
      return false
    end
  end

  # @param user [User] The (local, database) user whose data you want to update
  # @param user_data [Net::LDAP::Entry] The LDAP entry (it could also just be
  # a hash of hashes and arrays that looks like a Net::LDAP::Entry) of that user
  def update_user(user, user_data)
    ldaphelper = LdapHelper.new
    logger = LdapHelper::get_logger()
    unless ldaphelper.configIsOk == true
      return
    end
    
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
  
  # Is the given user a member of some LDAP group? Uses several methods for LDAP search, 
  # each housed in its own subroutine for better readability.
  # @param user_data [Net::LDAP::Entry] The LDAP entry (it could also just be
  # a hash of hashes and arrays that looks like a Net::LDAP::Entry) of that user
  # @param group_dn [String] The distinguished name of the LDAP group you want to check for.
  # @return [Boolean] TRUE if user is a member of the group. FALSE if user is NOT a member of the group OR exception occured
  def user_is_member_of_ldap_group(user_data, group_dn)
    begin
      ldaphelper = LdapHelper.new
      logger = LdapHelper::get_logger()
      unless ldaphelper.configIsOk == true
        return false
      end
      
      ldap = ldaphelper.bind
      
      isGroupMember = false
      logger.debug("Looking for LDAP group membership in: #{group_dn}")
    
      #new method with additional features (nested groups)
      if isGroupMember == false
        logger.debug("Search method: nested.")
        if (ldaphelper.look_in_nested_groups_for_membership == true) and
          (user_is_member_of_ldap_group_method_nested(user_data, group_dn, ldap, ldaphelper, logger) == true)
            isGroupMember = true
        end
      end
      
      #also new. Primary group membership needs to be handled differently
      if isGroupMember == false
        logger.debug("Search method: primary group.")
        if (ldaphelper.look_for_primary_group_membership_ActiveDirectory == true) and
          (user_is_member_of_ldap_group_method_primary(user_data, group_dn, ldap, ldaphelper, logger) == true)
          isGroupMember = true
        end
      end
      
      #Old, time-tested method
      if isGroupMember == false
        logger.debug("Search method: simple.")
        if (user_is_member_of_ldap_group_method_simple(user_data, group_dn, ldap, ldaphelper, logger) == true)
          isGroupMember = true
        end
      end
      
      if isGroupMember == true
        logger.info("User logging in is a member of group #{group_dn}:" \
            "#{user_data['cn']}")
        return true
      else
        logger.debug("User logging in is *not* a member of group #{group_dn}:" \
            "#{user_data['cn']}")
        return false
      end
      
    rescue Exception => e
      logger.error("ERROR: Could not query LDAP group membership of user '#{user_data.dn}' for group '#{group_dn}' " \
                   "Exception: #{e}" \
                   "#{e.backtrace.slice(1,500)}...")
      flash[:error] = _('Unexpected error while querying for LDAP group membership. Please contact your leihs system administrator.')
      return false
    end
  end
  
  #Subroutine of user_is_member_of_ldap_group(user_data, group_dn)
   def user_is_member_of_ldap_group_method_primary(user_data, group_dn, ldap, ldaphelper, logger)
    #Look at the primary group of the user (Default in AD: Domain-Users)
    #This is one plain Integer attribute of the user, representing the primary group id.
    #Completely different mechanism than the usual groups handled with the other methods.
    #Works only for ActiveDirectory, because we compare MS proprietary LDAP attributes (?)
    #Function should be save to be called in different environments, though.
    
    #Warning: the Primary Group ID uses non-unique values. They are only unique in their respective Active
    #Directory domains. If the primary Group of a user is set to 513, for example, he could be detected as a member
    #of Group 513 in the other domain too. This could be a potential security problem, if the user is able to log in to both 
    #AD domains.

    #logger.debug("myDebug Primary Group ID of user: #{user_data['primaryGroupID']}")

    #Filter
    #We are looking only for objects of class "group".
    groupObjFilter = Net::LDAP::Filter.eq("objectClass", "group")
    #Attributes. Array of strings.
    #We need to request primaryGroupToken explicitly, because it is calculated on the fly.
    #Attribute will be nonexistent otherwise.
    groupObjAttributes = ["primaryGroupToken"]
    
    #should return 1 Net::LDAP::Entry object, representing the group we are comparing against
    groupObjSearch = ldap.search(base: group_dn, filter: groupObjFilter, attributes: groupObjAttributes, scope: Net::LDAP::SearchScope_BaseObject)
  
    if groupObjSearch.nil?
      logger.error("LDAP search for group returned NIL result (while looking for Primary Group), which should not happen. Probably the following group does not exist in LDAP. Check your LDAP config file." \
                  "#{group_dn}")
      flash[:error] = _('There is a problem with LDAP group configuration. Please contact your leihs system administrator.')
    elsif groupObjSearch.count == 1
      #we found the primary group LDAP object
      groupObj = groupObjSearch.first
      
      #logger.debug("myDebug groupObj: #{groupObj.dn}")
      #logger.debug("myDebug groupObj.primaryGroupToken: #{groupObj['primaryGroupToken']}")
      
      #the user is a member of this group, if the primaryGroupToken and primaryGroupID values match
      if user_data['primaryGroupID'] == groupObj['primaryGroupToken']
        return true
      end
    end
    
    return false
  end

  #Subroutine of user_is_member_of_ldap_group(user_data, group_dn)
  def user_is_member_of_ldap_group_method_nested(user_data, group_dn, ldap, ldaphelper, logger)
    #New method of searching for group membership, using special LDAP syntax
    #Returns true for simple group membership *and* nested group membership
    #Example for nested groups:
    #user is member in group, group is member in group2
    # -> is user a member of group2? Yes, he is!
    #I only tested this with Active Directory, Server 2012
    #SHOULD work for other LDAP flavours too, because the magic number the search
    #uses is defined in RFC2254 which applies not only to Microsoft
    #DerBachmannRocker 2016.5.25
    
    #Example code for search of nested group memebership. stolen from cpan NET::LDAP
    #See also Microsoft documentation at
    #https://msdn.microsoft.com/en-us/library/aa746475%28v=vs.85%29.aspx
    #  #$mesg = $ldap->search( base   => 'dc=your,dc=ads,dc=domain',
    #                   filter => '(member:1.2.840.113556.1.4.1941:=cn=TestUser,ou=Users,dc=your,dc=ads,dc=domain)',
    #                   attrs  => [ '1.1' ]
    #                 );
    
    #construct a filter from string, according to RFC2254 syntax. Returns Filter object, needed for search 
    nested_group_filter = Net::LDAP::Filter.construct("member:#{ldaphelper.LDAP_MATCHING_RULE_IN_CHAIN}:=#{user_data.dn}")
    #nested_group_filter example value: (member:1.2.840.113556.1.4.1941:=CN=leihstest,OU=Static,OU=HumanUsers,OU=mht_Users,DC=mhtnet,DC=mh-trossingen,DC=de)
  
    #### Parameters ###
    #base: limit scope of search. look only inside group_dn LDAP tree
    #search for all (nested and simple) group memberships of the user EXCLUDING the primary group
    #use LDAP_return_only_DN, because we do not want other types of results to be returned
    #(possibly not needed, but included to match example above)
    nestedGroupSearchResult = ldap.search(base: group_dn, filter: nested_group_filter, attrs: ldaphelper.LDAP_return_only_DN)
  
    unless nestedGroupSearchResult
      logger.error("LDAP search for group returned NIL result (while looking for nested groups), which should not happen. Probably the following group does not exist in LDAP. Check your LDAP config file." \
                  "#{group_dn}")
      flash[:error] = _('There is a problem with LDAP group configuration. Please contact your leihs system administrator.')
    else
      #we have found the group membership we are looking for, if the search result was not empty
      #this should normally be 1
      if (nestedGroupSearchResult.count >= 1)
        return true
      end
    end
    
    return false
  end
  
  #Subroutine of user_is_member_of_ldap_group(user_data, group_dn)
  def user_is_member_of_ldap_group_method_simple(user_data, group_dn, ldap, ldaphelper, logger)
    #old method of search. Ignores nested groups
    #This is executed if the new method returns no result and or is disabled
    #I kept this method of search in, because I can only test with Active Directory and I do not want to break
    #login for different LDAP installations (Samba, etc.). Maybe they do not respond to the magic number search filter of the new method?
    #Code may be removed if tests on other LDAP installations are successful in the future
    #DerBachmannRocker 2016.5.25
    
    simple_group_filter = Net::LDAP::Filter.eq('member', user_data.dn)
    simpleGroupSearchResult = ldap.search(base: group_dn, filter: simple_group_filter)
  
    unless simpleGroupSearchResult
      logger.error("LDAP search for group returned NIL result (using default search method), which should not happen. Probably the following group does not exist in LDAP. Check your LDAP config file." \
                  "#{group_dn}")
      flash[:error] = _('There is a problem with LDAP group configuration. Please contact your leihs system administrator.')
    else 
      #user_data['memberof'].include?(group_dn) seems to be unneccessary for Active Directory
      if ((simpleGroupSearchResult.count >= 1) or
            (user_data['memberof'] and user_data['memberof'].include?(group_dn)))
        return true
      end
    end
    
    return false
  end


  def create_and_login_from_ldap_user(ldap_user, username, password)
    logger = LdapHelper::get_logger()
    
    begin  
      #check for mandatory user fields

      #email address is mandatory for account creation
      #Made decision to show error instead of creating user with dummy mail address
      #This did not work before anyways. leihs crashed if LDAP user logged on with no email set in LDAP
      #so below code is *no new behaviour* and admins needed to set the email correctly anyways.
      #Probably better to show error if undefined and quit than to assign dummy value
      #Line that caused crash and its ELSE path:
      #email = ldap_user.mail.first.to_s if ldap_user.mail
      #email ||= "#{user}@localhost"
      #Replaced by:
      if (not ldap_user['mail'].blank?) and (ldap_user.mail.first.to_s != '')
        #warning: be careful to leave check for blank email in first position of the AND operator.
        #Active directory does not return the attribute "mail" at all when left blank.
        #exception in this case, when accessing ldap_user.mail (because == NIL)
        email = ldap_user.mail.first.to_s
      else
        logger.error("LDAP user with blank eMail attribute attempted login: #{username}")
        flash[:error] = \
          _("Unable to login. Your user account has no eMail address set. Please contact your leihs system administrator.")
        return
      end
      
      if (not ldap_user['givenname'].blank?) and (ldap_user.givenname.to_s != '')
        firstname = ldap_user.givenname.to_s
      else
        logger.error("LDAP user with blank givenname (first name) attribute attempted login: #{username}")
        flash[:error] = \
          _("Unable to login. Your user account has no first name set. Please contact your leihs system administrator.")
        return
      end
      
      if (not ldap_user['sn'].blank?) and (ldap_user.sn.to_s != '')
        lastname = ldap_user.sn.to_s
      else
        logger.error("LDAP user with blank sn (family name) attribute attempted login: #{username}")
        flash[:error] = \
        _("Unable to login. Your user account has no family name set. Please contact your leihs system administrator.")
        return
      end
      #should be uncritical. every LDAP::Entry object should have this set
      bind_dn = ldap_user.dn
    rescue Exception => e
      logger.error("Unexpected exception while checking required LDAP user attributes for user #{username}:" \
                  "Exception: #{e}")
      flash[:error] = \
      _("Unable to login. Unexpected error. Please contact your leihs system administrator.")
    end

    #checks passed. create user / log in
    begin
      ldaphelper = LdapHelper.new
      unless ldaphelper.configIsOk == true
        return
      end

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
        logger.debug("Updated address data from LDAP for user #{username}.")
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
      _("Unable to login. Unexpected error. Please contact your leihs system administrator.")
    end
  end

  def login
    super
    @preferred_language = Language.preferred(request.env['HTTP_ACCEPT_LANGUAGE'])
    
    #this will validate the LDAP config file. informing the user of the result is handled by validate_configuration()
    ldaphelper = LdapHelper.new
    
    logger = LdapHelper::get_logger()
    
    if request.post? and (ldaphelper.configIsOk == true)
      username = params[:login][:user]
      password = params[:login][:password]
      if username == '' || password == ''
        flash[:notice] = _('Empty Username and/or Password')
      else
        logger.info("LDAP user trying to log in: #{username}")
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
              user_data = users.first
              normal_users_dn = ldaphelper.normal_users_dn
              admin_users_dn = ldaphelper.admin_dn
              
              user_allowed = false
              #Normal users group member? 
              if normal_users_dn == ''
                #normal_users_dn may be left blank in config. in this case any user who is able to bind to ldap may log in
                logger.warn("Any LDAP users may log in to leihs: normal_users_dn is blank in config. Check config / ignore this message.")
                user_allowed = true
              elsif user_is_member_of_ldap_group(user_data, normal_users_dn)
                logger.info("User is a member of normal users LDAP group. Access granted.")
                user_allowed = true
              end
              
              #Admin group member?
              if user_is_member_of_ldap_group(user_data, admin_users_dn)
                logger.info("User is a member of ADMIN users LDAP group. Access granted.")
                user_allowed = true                
              end
              
              if user_allowed == true
                create_and_login_from_ldap_user(user_data, username, password)
              else
                flash[:error] = _("You are not allowed to use leihs at the moment. Please contact your leihs system administrator.")
                logger.warn ("User was denied access, because he/she is not member of LDAP leihs users and/or admin group: #{user_data['cn']}")
              end
            else
              flash[:error] = _("User unknown") if users.size == 0
              if users.size > 0
                 flash[:error] = _("Too many users found")
                 logger.error("Too many users in LDAP matching given username. This should not happen. User login: #{username}")
              end
            end
            # rubocop:enable Metrics/BlockNesting
          else
            flash[:error] = _("Unable to connect to LDAP - contact your leihs system administrator!")
            logger.error("Unable to bind to LDAP! ldaphelper.bind returned NIL. Check LDAP config file. (master_bind_dn, master_bind_pw, etc.)")
          end
        rescue Net::LDAP::LdapError
          flash[:error] = _("Couldn't connect to LDAP server: " \
                            "#{ldaphelper.host}:#{ldaphelper.port}")
        end
      end
    else
      validate_configuration()
    end
  end

end
