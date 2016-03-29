require 'net/http'
require 'net/https'
require 'cgi'
class Authenticator::ZhdkController < Authenticator::AuthenticatorController

  AUTHENTICATION_URL = 'https://www.zhdk.ch/?auth/leihs2'
  APPLICATION_IDENT = '7f6d33ca2ad44359c826e2337d9315b1'
  SUPER_USERS = ['e157339|zhdk',
                 'e159123|zhdk',
                 'e10262|zhdk',
                 'e162205|zhdk',
                 'e171014|zhdk'] # Jerome, Franco, Ramon, Tomáš
  AUTHENTICATION_SYSTEM_CLASS_NAME = 'Zhdk'

  def login_form_path
    '/authenticator/zhdk/login'
  end

  def login
    super
    redirect_to target
  end

  def target
    AUTHENTICATION_URL \
      + '&url_postlogin=' \
      + CGI::escape("http://#{request.host}:#{request.port}" \
                    "#{url_for('/authenticator/zhdk/login_successful/%s')}")
  end

  def login_successful(session_id = params[:id])
    response = fetch("#{AUTHENTICATION_URL}/response" \
                     "&agw_sess_id=#{session_id}" \
                     "&app_ident=#{APPLICATION_IDENT}")
    if response.code.to_i == 200
      xml = Hash.from_xml(response.body)
      # old# uid = xml["authresponse"]["person"]["uniqueid"]
      self.current_user = create_or_update_user(xml)
      redirect_back_or_default('/') # TODO: #working here#24
    else
      render text: 'Authentication Failure. HTTP connection failed ' \
                   "- response was #{response.code}"
    end
  end

  def create_or_update_user(xml)
    return false unless xml['authresponse']['person']
    uid = xml['authresponse']['person']['uniqueid']
    email = xml['authresponse']['person']['email'] || uid + '@leihs.zhdk.ch'
    phone = "#{xml['authresponse']['person']['phone_mobile']}"
    phone = "#{xml['authresponse']['person']['phone_business']}" if phone.blank?
    phone = "#{xml['authresponse']['person']['phone_private']}" if phone.blank?
    user = \
      User.where(unique_id: uid).first \
      || User.where(email: email).first \
      || User.new
    user.unique_id = uid
    user.email = email
    user.phone = phone
    user.firstname = "#{xml['authresponse']['person']['firstname']}"
    user.lastname = "#{xml['authresponse']['person']['lastname']}"
    user.login = "#{user.firstname} #{user.lastname}"
    user.address = "#{xml['authresponse']['person']['address1']}, " \
                   "#{xml['authresponse']['person']['address2']}"
    user.zip = "#{xml['authresponse']['person']['countrycode']}-" \
               "#{xml['authresponse']['person']['zip']}"
    user.country = "#{xml['authresponse']['person']['country_de']}"
    user.city = "#{xml['authresponse']['person']['place']}"
    user.authentication_system = \
      AuthenticationSystem
        .where(class_name: AUTHENTICATION_SYSTEM_CLASS_NAME)
        .first
    user.extended_info = xml['authresponse']['person']
    user.save

    if SUPER_USERS.include?(user.unique_id)
      user.access_rights.create(role: :admin, inventory_pool: nil)
    end
    user
  end

  private

  def fetch(uri_str, limit = 10)
     raise ArgumentError, 'HTTP redirect too deep' if limit == 0

     uri = URI.parse(uri_str)
     http = Net::HTTP.new(uri.host, uri.port)
     http.use_ssl = true if uri.port == 443
     response = http.get(uri.path + '?' + uri.query)
     case response
     when Net::HTTPSuccess     then response
     when Net::HTTPRedirection then fetch(response['location'], limit - 1)
     else
         response.error!
     end
  end

end
