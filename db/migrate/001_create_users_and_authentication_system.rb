class CreateUsersAndAuthenticationSystem < ActiveRecord::Migration

  def self.up
    create_table :authentication_systems do |t|
      t.string :name
      t.string :class_name
    end
    
    AuthenticationSystem.new(:name => "Database Authentication", :class_name => "DatabaseAuthentication").save
    AuthenticationSystem.new(:name => "LDAP Authentication", :class_name => "LDAPAuthentication").save
    
    create_table :users do |t|
      t.string :login             
      t.belongs_to :authentication_system, :default => 1
      t.timestamps
    end
    
  end

  def self.down
    drop_table :users
    drop_table :authentication_systems
  end
end
