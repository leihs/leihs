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

    Setting.create(
      :smtp_address => ActionMailer::Base.smtp_settings[:address],
      :smtp_port => ActionMailer::Base.smtp_settings[:port],
      :smtp_domain => ActionMailer::Base.smtp_settings[:domain],
      :local_currency_string => LOCAL_CURRENCY_STRING,
      :contract_terms => CONTRACT_TERMS,
      :contract_lending_party_string => CONTRACT_LENDING_PARTY_STRING,
      :email_signature => EMAIL_SIGNATURE,
      :default_email => DEFAULT_EMAIL,
      :deliver_order_notifications => DELIVER_ORDER_NOTIFICATIONS,
      :user_image_url => USER_IMAGE_URL
    )

  end

end
