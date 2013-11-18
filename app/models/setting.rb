class Setting < ActiveRecord::Base

  validates_presence_of :local_currency_string,
                        :email_signature,
                        :default_email

  #validates_numericality_of :smtp_port, :greater_than => 0

  validates_format_of :default_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  def self.initialize_constants
    singleton = first # fetch the singleton from the database
    return unless singleton
    silence_warnings do
      [:smtp_address,
       :smtp_port,
       :smtp_domain,
       :mail_delivery_method,
       :local_currency_string,
       :contract_terms,
       :contract_lending_party_string,
       :email_signature,
       :default_email,
       :deliver_order_notifications,
       :user_image_url,
       :ldap_config,
       :logo_url].each do |k|
        Setting.const_set k.to_s.upcase, singleton.send(k) if singleton.methods.include?(k)
      end
    end
  end

  # initialize the constants at the application startup
  initialize_constants

  before_create do
    raise "Setting is a singleton" if Setting.count > 0
  end

  after_save do
    self.class.initialize_constants
  end

end
