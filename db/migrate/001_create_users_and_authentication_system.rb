class CreateUsersAndAuthenticationSystem < ActiveRecord::Migration

  def self.up
    create_table :authentication_systems do |t|
      t.string :name
      t.string :class_name
    end
    
    AuthenticationSystem.new(:name => "Database Authentication", :class_name => "DatabaseAuthentication").save
    AuthenticationSystem.new(:name => "LDAP Authentication", :class_name => "LDAPAuthentication").save
    
    create_table :users do |t|
      t.string :login # restful_authentication             
      t.belongs_to :authentication_system, :default => 1
      t.timestamps

      # Start restful_authentication
      # TODO refactor dedicated authentication_system
      t.string :email
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.datetime :created_at
      t.datetime :updated_at
      t.string :remember_token
      t.datetime :remember_token_expires_at
      # End restful_authentication
    
    end

    
  end

  def self.down
    drop_table :users
    drop_table :authentication_systems
  end
end
