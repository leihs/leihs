module Factory
  
  def self.create_user(attributes = {})
    default_attributes = {
      :login => "jerome",
      :email  => "jerome@example.com",
    }
    u = User.create default_attributes.merge(attributes)
    u.save
    u
  end
  
  def self.create_order(attributes = {})
    default_attributes = {
      
    }
    o = Order.create default_attributes.merge(attributes)
    o.save
    o
  end

end