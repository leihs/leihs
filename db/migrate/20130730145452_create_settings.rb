class CreateSettings < ActiveRecord::Migration

  # TODO this hack is required in order to skip validations when the setting is created further below. The creation of setting would fail otherwise due to missing validations methods which are added to the Setting model in later migrations
  class ::Setting < ActiveRecord::Base
  end

  def change

    create_table :settings, :force => true do |t|
      t.string  :smtp_address
      t.integer :smtp_port
      t.string  :smtp_domain
      t.string  :local_currency_string
      t.text    :contract_terms
      t.text    :contract_lending_party_string
      t.string  :email_signature
      t.string  :default_email
      t.boolean :deliver_order_notifications
      t.string  :user_image_url
      t.string  :ldap_config
    end

    h = {}
    h[:smtp_address]                  = ActionMailer::Base.smtp_settings[:address]  if ActionMailer::Base.smtp_settings[:address]
    h[:smtp_port]                     = ActionMailer::Base.smtp_settings[:port]     if ActionMailer::Base.smtp_settings[:port]
    h[:smtp_domain]                   = ActionMailer::Base.smtp_settings[:domain]   if ActionMailer::Base.smtp_settings[:domain]
    h[:local_currency_string]         = LOCAL_CURRENCY_STRING                       if Leihs::Application.const_defined? :LOCAL_CURRENCY_STRING
    h[:contract_terms]                = CONTRACT_TERMS                              if Leihs::Application.const_defined? :CONTRACT_TERMS
    h[:contract_lending_party_string] = CONTRACT_LENDING_PARTY_STRING               if Leihs::Application.const_defined? :CONTRACT_LENDING_PARTY_STRING
    h[:email_signature]               = EMAIL_SIGNATURE                             if Leihs::Application.const_defined? :EMAIL_SIGNATURE
    h[:default_email]                 = DEFAULT_EMAIL                               if Leihs::Application.const_defined? :DEFAULT_EMAIL
    h[:deliver_order_notifications]   = DELIVER_ORDER_NOTIFICATIONS                 if Leihs::Application.const_defined? :DELIVER_ORDER_NOTIFICATIONS
    h[:user_image_url]                = USER_IMAGE_URL                              if Leihs::Application.const_defined? :USER_IMAGE_URL

    # Create some sane defaults if they couldn't be exctracted from the application.rb, e.g.
    # if application.rb is empty.
    h[:smtp_address]                  ||= "localhost"
    h[:smtp_port]                     ||= 25
    h[:smtp_domain]                   ||= "example.com"
    h[:local_currency_string]         ||= "GBP"
    h[:contract_terms]                ||= nil
    h[:contract_lending_party_string] ||= nil
    h[:email_signature]               ||= "Cheers,"
    h[:default_email]                 ||= "your.lending.desk@example.com"
    h[:deliver_order_notifications]   ||= false
    h[:user_image_url]                ||= nil

    setting = Setting.new(h) unless h.empty?
    if setting.save
      puts "Settings created: #{h}"
    else
      raise "Settings could not be created: #{setting.errors.full_messages}"
    end

  end

end
