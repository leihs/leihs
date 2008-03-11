class User < ActiveRecord::Base

  belongs_to :authentication_system
  
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
