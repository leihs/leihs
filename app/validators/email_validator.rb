class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,attribute,value)
    unless value.to_s.empty? 
      valid = value =~ /^[\[_a-z0-9\-\]]+(\.[\[\]_A-Za-z0-9\-]+)*@[a-z0-9]+(\.[_A-Za-z0-9\-]+)*(\.[A-Za-z]{2,})$/
      errors.add(:name, "#{value} is not a valid email address") unless valid
    end
  end
end