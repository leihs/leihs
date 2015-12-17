class AuthenticationSystem < ActiveRecord::Base
  audited

  scope :default_system, -> { where(is_default: true) }
  scope :active_systems, -> { where(is_active: true) }

  # TODO: single table inheritance
  def missing_required_fields(user)
    case self.class_name
    when 'Zhdk'
        required_fields = [:email, :phone, :address, :zip, :city]
        if !user.email.blank? \
          and !user.extended_info.try(:fetch, 'email_alt').blank?
          required_fields.delete(:email)
        end
        if !user.phone.blank? \
          or !user.extended_info.try(:fetch, 'phone_mobile').blank?
          required_fields.delete(:phone)
        end
        required_fields.delete(:address) unless user.address.blank?
        required_fields.delete(:zip) unless user.zip.blank?
        required_fields.delete(:city) unless user.city.blank?
        required_fields
    else
        []
    end
  end

end
