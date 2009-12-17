class CreateDatabaseAuthentications < ActiveRecord::Migration
  def self.up
    create_table :database_authentications do |t|
      t.string :login
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.belongs_to :user
      t.timestamps
    end
    
  end

  def self.down
    drop_table :database_authentications
  end
end
