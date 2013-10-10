class CreateSettings < ActiveRecord::Migration

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

    Setting.create(h) unless h.empty?

  end

end
