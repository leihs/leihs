class AddSmtpUsernameAndPassword < ActiveRecord::Migration
  def change
    change_table(:settings) do |t|
      t.string :smtp_username
      t.string :smtp_password
    end
  end
end
