class AuthenticationSystem < ActiveRecord::Base

  named_scope :default_system, :conditions => { :default => true }
  named_scope :active_systems, :conditions => { :active => true }
  
end
