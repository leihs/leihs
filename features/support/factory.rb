module Factory

  ##########################################
  #
  # Various sets of data for different uses
  #
  ##########################################

  #
  # Simple dataset with
  # * manager, customer, model and an item
  #
  def self.create_dataset_simple
    
    inventory_pool = Factory.create_inventory_pool_default_workdays
        
    # Create Manager
    user = Factory.create_user( {:login => 'inv_man'},
                                {:role => "manager",
                                 :inventory_pool => inventory_pool})
    # Create Customer
    customer = Factory.create_user( {:login => 'customer'},
				    {:role => "customer",
                                     :inventory_pool => inventory_pool})
    # Create Model and Item
    model = Factory.create_model(:name => 'holey parachute')
    Factory.create_item(:model => model, :inventory_pool => inventory_pool)
    
    [inventory_pool, user, customer, model]
  end

  ##########################################
  #
  # Creating Models
  #
  ##########################################

  #
  # Language
  # 
  def self.create_language!(attributes = {}, options = {})
    default_attributes = {
      :default => false,
      :active  => true
    }
    Language.create! default_attributes.merge(attributes)
  end

  #
  # User
  # 
  def self.create_user(attributes = {}, options = {})
    default_attributes = {
      :login => "jerome",
      :email  => "jerome@example.com",
      :language_id => 2
    }
    default_attributes[:email] = "#{attributes[:login].gsub(' ', '_')}@example.com" if attributes[:login]
    u = User.find_or_create_by_login default_attributes.merge(attributes)
    
    options[:role] ||= "customer"
    options[:inventory_pool] ||= InventoryPool.first
    Factory.define_role(u, options[:inventory_pool], options[:role] )

    u.save
    u
  end

  #
  # Role
  # 
  def self.define_role(user, inventory_pool, role_name = "manager" )
    role = Role.find_or_create_by_name(:name => role_name)
    begin
      user.access_rights.create(:role => role,
                                :inventory_pool => inventory_pool)
    rescue
      # unique index, record already present
    end
  end

  #
  # Date
  # 
  def self.random_future_date
    # future date is within the next 3 years, at earliest tomorrow
    Date.today + rand(3*365).days + 1.day
  end

  #
  # Order
  # 
  def self.create_order(attributes = {}, options = {})
    default_attributes = {
      :inventory_pool => create_inventory_pool(:name => "ABC")
    }
    o = Order.create default_attributes.merge(attributes)
    options[:order_lines].times do |i|
        model = Factory.create_model(:name => "model_#{i}" )
        quantity = rand(3) + 1
        quantity.times {
            Factory.create_item( :model => model,
                                 :inventory_pool => o.inventory_pool )
        }
        d = [ self.random_future_date, self.random_future_date ]
        o.add_line(quantity, model, o.user_id, d.min, d.max )
    end if options[:order_lines]
    o.save
    o
  end

  #
  # Contract
  # 
  # copied from create_order
  def self.create_contract(attributes = {}, options = {})
    default_attributes = {
      :inventory_pool => create_inventory_pool(:name => "ABC")
    }
    c = Contract.create default_attributes.merge(attributes)
    options[:contract_lines].times { |i|
        model = Factory.create_model(:name => "model_#{i}" )
        quantity = rand(3) + 1
        quantity.times {
	  Factory.create_item( :model => model,
			       :inventory_pool => c.inventory_pool)
	}
        d = [ self.random_future_date, self.random_future_date ]
        c.add_line(quantity, model, c.user_id, d.min, d.max )
    } if options[:order_lines]
    c.save
    c
  end
      
  #
  # Model
  # 
  def self.create_model(attributes = {})
    default_attributes = {
      :name => 'model_1'
    }
    t = Model.find_or_create_by_name default_attributes.merge(attributes)
    t.save
    t
  end

  #
  # inventory code
  # 
  def self.generate_new_unique_inventory_code
    begin
      chars_len = 1
      nums_len = 2
      chars = ("A".."Z").to_a
      nums = ("0".."9").to_a
      code = ""
      1.upto(chars_len) { |i| code << chars[rand(chars.size-1)] }
      1.upto(nums_len) { |i| code << nums[rand(nums.size-1)] }
    end while Item.exists?(:inventory_code => code)
    code
  end
  
  #
  # Item
  # 
  def self.create_item(attributes = {})
    default_attributes = {
      :inventory_code => generate_new_unique_inventory_code,
      :is_borrowable => true
    }
    i = Item.create default_attributes.merge(attributes)
    i
  end
  
  #
  # parsedate
  # 
  def self.parsedate(str)
    match = /(\d{1,2})\.(\d{1,2})\.(\d{2,4})\.?/.match(str)
    unless match
      ret = ParseDate.old_parsedate(str)
    else
      ret = [match[3].to_i, match[2].to_i, match[1].to_i, nil, nil, nil, nil, nil] 
    end
    DateTime.new(ret[0], ret[1], ret[2]) # TODO Date
  end

  #
  # OrderLine
  # 
  def self.create_order_line(options = {})
      model = Factory.create_model :name => options[:model_name]

      if options[:start_date]
        start_date = parsedate(options[:start_date])
        end_date = start_date + 2.days
      else
        d = [ self.random_future_date, self.random_future_date ]
        start_date = d.min
        end_date = d.max
      end
      
      ol = OrderLine.new(:quantity => options[:quantity],
                         :model_id => model.to_i,
                         :start_date => start_date,
                         :end_date => end_date,
                         :inventory_pool => options[:inventory_pool])
      ol              
  end

  #
  # ContractLine
  # 
  def self.create_contract_line(options = {})
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
      
      ol = ContractLine.new(:quantity => options[:quantity],
                            :model_id => model.to_i,
                            :start_date => start_date,
                            :end_date => end_date)
      ol              
  end

  #
  # InventoryPool
  # 
  def self.create_inventory_pool(attributes = {})
    default_attributes = {
      :name => "ABC" 
    }
    ip = InventoryPool.find_by_name default_attributes.merge(attributes)[:name]
    if ip.nil?
      ip = InventoryPool.create default_attributes.merge(attributes)
      w = ip.workday
      w.sunday = true
      w.saturday = true
      w.save
    end
    ip
  end

  #
  # InventoryPool workdays
  # 
  def self.create_inventory_pool_default_workdays(attributes = {})
    default_attributes = {
      :name => "ABC" 
    }
    ip = InventoryPool.find_or_create_by_name(
             default_attributes.merge(attributes)[:name] )
    ip
  end


  #
  # Category
  # 
  def self.create_category(attributes = {})
    default_attributes = {
      :name => 'category'
    }
    t = Category.find_or_create_by_name default_attributes.merge(attributes)
    t
  end

  
end
