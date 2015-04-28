class EmailValidator < ActiveModel::EachValidator
  def validate_each(record,_attribute,value)
    
    unless value.to_s.empty? # email can be blank 
      
      # validate email syntax
      valid = (value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i) ? true : false
      record.errors.add("#{value} is not a valid email address") unless valid
      
    end
  end
end