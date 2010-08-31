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

  $general_layout_path = 'layouts/backend/' + $theme + '/general'
     
  layout $general_layout_path
        
  
  
  def login
    # Handle Shibboleth environment variables here.
    # Create users locally that don't exist.
    # Overwrite local user attributes with ones freshly forwarded from Shibboleth.
  end  
end