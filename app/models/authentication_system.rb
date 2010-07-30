class AuthenticationSystem < ActiveRecord::Base

  named_scope :default_system, :conditions => { :is_default => true }
  named_scope :active_systems, :conditions => { :is_active => true }

  # TODO single table inheritance
  def missing_required_fields(user)
    case self.class_name
      when "Zhdk"
        required_fields = [:email, :phone]
        required_fields.delete(:email) if !user.email.blank? and !user.extended_info["email_alt"].blank?
        required_fields.delete(:phone) if !user.phone.blank? or !user.extended_info["phone_mobile"].blank?
        required_fields
      else
        []
    end
  end
  
  
end
