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
  
  def self.parsedate(str)
    match = /(\d{1,2})\.(\d{1,2})\.(\d{2,4})\.?/.match(str)
    unless match
      ret = ParseDate.old_parsedate(str)
    else
      ret = [match[3].to_i, match[2].to_i, match[1].to_i, nil, nil, nil, nil, nil] 
    end
    DateTime.new(ret[0], ret[1], ret[2])
  end
  
end