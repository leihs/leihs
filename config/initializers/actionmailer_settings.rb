class ActionMailer::Base

  def self.smtp_settings
    # If you don't check for the existence of a settings table, you will break
    # Rails initialization and so e.g. rake db:migrate no longer works. So
    # having no settings table will break initialization of the Rake task that
    # creates the settings table in the first place (!), creating a chicken and
    # egg problem.
    if ActiveRecord::Base.connection.tables.include?("settings")
      settings = {
        :address => Setting::SMTP_ADDRESS,
        :port => Setting::SMTP_PORT,
        :domain => Setting::SMTP_DOMAIN,
        :enable_starttls_auto => true,
        :openssl_verify_mode => 'none'
      }

      # Catch NameError if these settings aren't defined
      begin
        if Setting::SMTP_USERNAME and Setting::SMTP_PASSWORD
          auth_settings = {
            :user_name => Setting::SMTP_USERNAME,
            :password => Setting::SMTP_PASSWORD
          }
          settings.merge!(auth_settings)
        end
      rescue
      end
    else
      # Set some silly defaults
      settings = {
        :address => "localhost",
        :port => 25,
        :domain => "localhost",
        :enable_starttls_auto => false,
        :openssl_verify_mode => 'none'
      }
    end
    return settings
  end

  def self.delivery_method
    begin
      delivery_method = Setting::MAIL_DELIVERY_METHOD
    rescue
      delivery_method = :smtp
    end
    return delivery_method
  end

end
