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

ActionMailer::Base.smtp_settings = settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.default :charset => 'utf-8'
