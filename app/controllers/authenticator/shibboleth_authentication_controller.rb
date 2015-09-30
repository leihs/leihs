# In order to use this Shibboleth authenticator, you must put the entire
# leihs instance behind a shibboleth "secure" location:
#
# <Location />
#    AuthType shibboleth
#    ShibRequireSession On
#    require valid-user
#  </Location>
#
# You must also have a working service provider (SP) for this instance.

class Authenticator::ShibbolethAuthenticationController < Authenticator::AuthenticatorController

  before_action :load_config
  layout 'layouts/manage/general'

  def load_config
    begin
      if (defined?(Setting::SHIBBOLETH_CONFIG) and not Setting::SHIBBOLETH_CONFIG.blank?)
        shibboleth_config = YAML::load_file(Setting::SHIBBOLETH_CONFIG)
      else
        shibboleth_config = YAML::load_file(File.join(Rails.root, 'config', 'shibboleth.yml'))
      end

      if shibboleth_config[Rails.env].nil?
        raise "The configuration section for the environment '#{Rails.env}' is missing in your shibboleth config file."
      else
        @config = shibboleth_config[Rails.env]
        validate_config
      end

      if @config['admin_uids']
        @super_users = @config['admin_uids']
      end
    rescue Exception => e
      raise "Shibboleth configuration file is invalid or not present: #{e}"
    end
  end

  def validate_config
    required_fields = %w(unique_id_field firstname_field lastname_field mail_field)
    required_fields.map do |field|
      if !@config[field] or @config[field].blank?
        raise "The Shibboleth configuration file is missing the '#{field}' setting."
      end
    end
  end

  def login_form_path
    '/authenticator/shibboleth/login'
  end

  def login
    super
    # This point should only be reached after a successful login from Shibboleth.
    # Shibboleth handles all error management, so we don't need to worry about any
    # of that.
    if request.env[@config['unique_id_field']].blank?
      redirect_to root_path
    else
      self.current_user = create_or_update_user
      redirect_to root_path
    end
  end

  def create_or_update_user
    # request.env after Shibboleth authentication looks like this:
    #    "uid"=>"e10262@zhdk.ch",
    #    "homeOrganizationType"=>"uas",
    #    "givenName"=>"Ramon",
    #    "Shib-AuthnContext-Class"=>"urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
    #    "Shib-Identity-Provider"=>"https://aai-logon.zhdk.ch/idp/shibboleth",
    #    "Shib-InetOrgPerson-givenName"=>"Ramon",
    #    "Shib-Authentication-Method"=>"urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport",
    #    "mail"=>"ramon.cahenzli@zhdk.ch",
    #    "Shib-SwissEP-HomeOrganization"=>"zhdk.ch",
    #    "Shib-Application-ID"=>"leihs2shib",
    #    "Shib-Person-surname"=>"Cahenzli",
    #    "Shib-EP-Affiliation"=>"faculty;staff;member",
    #    "Shib-Authentication-Instant"=>"2010-09-28T07:03:59.738Z",
    #    "Shib-SwissEP-UniqueID"=>"e10262@zhdk.ch",
    #    "Shib-SwissEP-HomeOrganizationType"=>"uas",
    #    "Shib-InetOrgPerson-mail"=>"ramon.cahenzli@zhdk.ch",
    #    "Shib-Session-ID"=>"_22d5e2f708f663eae29d2afeae08dfff",
    #    "surname"=>"Cahenzli", "homeOrganization"=>"zhdk.ch",
    #    "affiliation"=>"faculty;staff;member"

    uid = request.env[@config['unique_id_field']]
    email = request.env[@config['mail_field']]
    user = User.where(unique_id: uid).first || User.where(email: email).first || User.new
    user.unique_id = uid
    user.login = uid
    user.email = email
    user.firstname = "#{request.env[@config['firstname_field']]}"
    user.lastname = "#{request.env[@config['lastname_field']]}"
    user.authentication_system = AuthenticationSystem.where(class_name: 'ShibbolethAuthentication').first
    user.save
    unless user.errors.full_messages.blank?
      logger = Rails.logger
      logger.error user.errors.full_messages
    end

    if @super_users.include?(user.unique_id)
      user.access_rights.create(role: :admin, inventory_pool: nil)
    end
    user
  end

end
