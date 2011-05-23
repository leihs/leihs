# == Schema Information
#
# Table name: authentication_systems
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  class_name :string(255)
#  is_default :boolean(1)      default(FALSE)
#  is_active  :boolean(1)      default(FALSE)
#

# == Schema Information
#
# Table name: authentication_systems
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  class_name :string(255)
#  is_default :boolean(1)      default(FALSE)
#  is_active  :boolean(1)      default(FALSE)
#
class AuthenticationSystem < ActiveRecord::Base

  scope :default_system, :conditions => { :is_default => true }
  scope :active_systems, :conditions => { :is_active => true }

  # TODO single table inheritance
  def missing_required_fields(user)
    case self.class_name
      when "Zhdk"
        required_fields = [:email, :phone, :address, :zip, :city]
        required_fields.delete(:email) if !user.email.blank? and !user.extended_info.try(:fetch, "email_alt").blank?
        required_fields.delete(:phone) if !user.phone.blank? or !user.extended_info.try(:fetch, "phone_mobile").blank?
        required_fields.delete(:address) unless user.address.blank?
        required_fields.delete(:zip) unless user.zip.blank?
        required_fields.delete(:city) unless user.city.blank?
        required_fields
      else
        []
    end
  end
  
  
end
