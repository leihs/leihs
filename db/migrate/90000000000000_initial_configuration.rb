class InitialConfiguration < ActiveRecord::Migration

  def self.up
  
    if AuthenticationSystem.count == 0
  
      AuthenticationSystem.create(:name => "Database Authentication", :class_name => "DatabaseAuthentication", :is_active => true, :is_default => true )
      AuthenticationSystem.create(:name => "LDAP Authentication", :class_name => "LDAPAuthentication", :is_default => false)
      AuthenticationSystem.create(:name => "ZHDK Authentication", :class_name => "Zhdk", :is_default => false)
    end
    
    #create roles
    if Role.count == 0
      r_a = Role.create(:name => "admin")
      
      r_im = Role.create(:name => "manager")
      r_im.move_to_child_of r_a
      
      r_s = Role.create(:name => "customer")
      r_s.move_to_child_of r_im
    end
  
    #create admin
    if User.count == 0 
      user = User.new(  :email => "super_user_1@example.com",
                        :login => "super_user_1")
  
      user.unique_id = "super_user_1"
      user.save
      r = Role.find(:first, :conditions => {:name => "admin"})
      
      user.access_rights.create(:role => r, :inventory_pool => nil)
      puts _("The administrator %{a} has been created ") % { :a => user.login }
    
      d = DatabaseAuthentication.find_or_create_by_login("super_user_1")
      d.password = "pass"
      d.password_confirmation = "pass"
      d.user = User.first
      d.save
    end
   
  end
  
  def self.down
#    AuthenticationSystem.delete(1)
#    AuthenticationSystem.delete(2)
#    AuthenticationSystem.delete(3)
#    
#    Role.delete(1)
#    Role.delete(2)
#    Role.delete(3)
#    
#    User.first.delete
  end
end
