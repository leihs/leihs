class CreateRolesAndRolesUsers < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|

      t.timestamps
    end

    create_table :roles_users do |t|
      t.belongs_to :role
      t.belongs_to :user
    end
  
  end

  def self.down
    drop_table :roles
  end
end
