class AuthenticationSystem < ActiveRecord::Base

  named_scope :default_system, :conditions => { :is_default => true }
  named_scope :active_systems, :conditions => { :is_active => true }
  
end
