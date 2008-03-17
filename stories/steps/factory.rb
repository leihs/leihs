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
  
  def self.create_model(attributes = {})
    default_attributes = {
      :name => 'model_1'
    }
    t = Model.create default_attributes.merge(attributes)
    t.save
    t
  end

  def self.create_item(attributes = {})
    default_attributes = {
      :inventory_code => "1"
      
    }
    
    i = Item.create default_attributes.merge(attributes)
    i.save
    i
  end
end