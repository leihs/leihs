class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :email
      t.string :login
      t.string :hashed_password

      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
