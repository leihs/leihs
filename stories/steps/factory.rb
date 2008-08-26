module Factory

  def self.create_user(attributes = {}, options = {})
    default_attributes = {
      :login => "jerome",
      :email  => "jerome@example.com",
    }
    u = User.find_or_create_by_login default_attributes.merge(attributes)
    
    Factory.define_role(u, options[:role]) if options[:role]

    u.save
    u
  end

  def self.define_role(user, role_name = "manager", inventory_pool_name = "ABC")
    role = Role.find_or_create_by_name(:name => role_name)
    inventory_pool = InventoryPool.find_or_create_by_name(:name => inventory_pool_name)
    begin
      user.access_rights << AccessRight.new(:role => role, :inventory_pool => inventory_pool)
    rescue
      # unique index, record already present
    end
  end

  def self.create_order(attributes = {}, options = {})
    default_attributes = {
      :inventory_pool => InventoryPool.find_or_create_by_name(:name => "ABC")
    }
    o = Order.create default_attributes.merge(attributes)
    options[:order_lines].times { |i|
        model = Factory.create_model(:name => "model_#{i}" )
        quantity = rand(3) + 1
        quantity.times { Factory.create_item(:model => model)}
        d = Array.new
        2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
        o.add_line(quantity, model, o.user_id, d.min, d.max )
    } if options[:order_lines]
    o.save
    o
  end
      
  def self.create_model(attributes = {})
    default_attributes = {
      :name => 'model_1'
    }
    t = Model.find_or_create_by_name default_attributes.merge(attributes)
    t.save
    t
  end

  
  def self.create_item(attributes = {})
    default_attributes = {
      :inventory_code => Item.get_new_unique_inventory_code,
      :location => Location.find_or_create_by_room(:room => "main_ABC",
                                                   :inventory_pool => InventoryPool.find_or_create_by_name(:name => "ABC")) 
    }
    i = Item.create default_attributes.merge(attributes)
    i
  end
  
  def self.parsedate(str)
    match = /(\d{1,2})\.(\d{1,2})\.(\d{2,4})\.?/.match(str)
    unless match
      ret = ParseDate.old_parsedate(str)
    else
      ret = [match[3].to_i, match[2].to_i, match[1].to_i, nil, nil, nil, nil, nil] 
    end
    DateTime.new(ret[0], ret[1], ret[2]) # TODO Date
  end

  def self.create_order_line(options = {})
      model = Factory.create_model :name => options[:model_name]

      if options[:start_date]
        start_date = parsedate(options[:start_date])
        end_date = start_date + 2.days
      else
        d = Array.new
        2.times { d << Date.new(rand(2)+2008, rand(12)+1, rand(28)+1) }
        start_date = d.min
        end_date = d.max
      end
      
      ol = OrderLine.new(:quantity => options[:quantity],
                         :model_id => model.to_i,
                         :start_date => start_date,
                         :end_date => end_date)
      ol              
  end

  def self.create_inventory_pool(attributes = {})
    default_attributes = {
      :name => "ABC" 
    }
    ip = InventoryPool.create default_attributes.merge(attributes)
    ip
  end

  def self.create_category(attributes = {})
    default_attributes = {
      :name => 'category'
    }
    t = Category.find_or_create_by_name default_attributes.merge(attributes)
    t
  end

  
end