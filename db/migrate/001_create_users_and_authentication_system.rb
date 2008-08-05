class CreateUsersAndAuthenticationSystem < ActiveRecord::Migration

  def self.up
    create_table :authentication_systems do |t|
      t.string :name
      t.string :class_name
      t.boolean :default
      t.boolean :active
    end
    
    AuthenticationSystem.create(:name => "Database Authentication", :class_name => "DatabaseAuthentication", :active => false)
    AuthenticationSystem.create(:name => "LDAP Authentication", :class_name => "LDAPAuthentication", :active => false)
    AuthenticationSystem.create(:name => "ZHDK Authentication", :class_name => "Zhdk", :active => true, :default => true)
    
    
    create_table :users do |t|
      t.string :login #TODO: Rename to 'name'
      t.belongs_to :authentication_system, :default => 1
      t.string :unique_id
      t.string :email
      t.timestamps
    
    end

    
  end

  def self.down
    drop_table :users
    drop_table :authentication_systems
  end
end
