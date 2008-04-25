class User < ActiveRecord::Base

  belongs_to :authentication_system
  has_and_belongs_to_many :roles
  
  acts_as_ferret :fields => [ :login ]  #, :store_class_name => true
    
  def authinfo
    @authinfo ||= Class.const_get(authentication_system.class_name).new(login)
  end
  
  def email=(email)
    authinfo.email = email
  end
  
  def email
    authinfo.email
  end
  
end
