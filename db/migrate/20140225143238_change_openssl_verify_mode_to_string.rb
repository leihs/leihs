class ChangeOpensslVerifyModeToString < ActiveRecord::Migration
  def up
    change_column :settings, :smtp_openssl_verify_mode, :string, :default => 'none'
  end

  def down
    change_column :settings, :smtp_openssl_verify_mode, :boolean
  end

end
