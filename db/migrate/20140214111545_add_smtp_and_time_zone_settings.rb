class AddSmtpAndTimeZoneSettings < ActiveRecord::Migration
  def change
    change_table(:settings) do |t|
      t.boolean :smtp_enable_starttls_auto, null: false, default: false
      t.boolean :smtp_openssl_verify_mode, null: false, default: false
      t.string :time_zone, null: false, default: 'Bern'
    end
  end
end
