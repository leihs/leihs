class CreateUsersAndAuthenticationSystem < ActiveRecord::Migration

  def self.up
    create_table :authentication_systems do |t|
      t.string :name
      t.string :class_name
      t.boolean :is_default, :default => false
      t.boolean :is_active, :default => false
    end
    
    AuthenticationSystem.create(:name => "Database Authentication", :class_name => "DatabaseAuthentication")
    AuthenticationSystem.create(:name => "LDAP Authentication", :class_name => "LDAPAuthentication")
    AuthenticationSystem.create(:name => "ZHDK Authentication", :class_name => "Zhdk", :is_active => true, :is_default => true)
    
    
    create_table :users do |t|
      t.string :login #TODO: Rename to 'name'
      t.belongs_to :authentication_system, :default => 1
      t.string :unique_id
      t.string :email
      t.timestamps
    end
    foreign_key :users, :authentication_system_id, :authentication_systems
    
  end

  def self.down
    drop_table :users
    drop_table :authentication_systems
  end
end
