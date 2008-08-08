steps_for(:availability_inventory_pool) do
    
  Given "$size inventory pools" do | size |
    size.to_i.times do |i|
      Factory.create_inventory_pool(:name => (i+1))
    end
    @inventory_pools = InventoryPool.all
    @inventory_pools.size.should == size.to_i
  end

  # duplicated from availability_inventory
  Given "a model '$model' exists" do | model |
    @model = Factory.create_model(:name => model)
  end  
  
  Given "this model has $number item$s in inventory pool $ip" do |number, s, ip|
    inventory_pool = InventoryPool.find_by_name(ip)
    number.to_i.times do | i |
      l = Location.find(:first, :conditions => {:name => "generic", :inventory_pool_id => inventory_pool.id})
      l = Location.create(:name => "generic", :inventory_pool => inventory_pool) unless l
      Factory.create_item(:model => @model, :location => l)
    end
    inventory_pool.items.count(:conditions => {:model_id => @model.id}).should == number.to_i
  end
  
  Given "user '$who' has access to inventory pool $ip_s" do |who, ip_s|
    user = Factory.create_user({:login => who
                                  #, :password => "pass"
                                })
    ip_s.split(" and ").each do |ip_name|
      Factory.define_role(user, "student", ip_name)
      user.inventory_pools.include?(InventoryPool.find_by_name(ip_name)).should == true
    end
  end

  Then "the maximum number of available '$model' for '$who' is $size" do |model, who, size|
    user = User.find_by_login(who)
    @model = Model.find_by_name(model)
    user.items.count(:conditions => {:model_id => @model.id}).should == size.to_i
  end
  
###########################################################################

  When "'$who' order$s $quantity '$model'" do |who, s, quantity, model|
    post "/session", :login => who #, :password => "pass"
    get "/orders/new"
    @order = assigns(:order)
    model_id = Model.find_by_name(model).id
    post "/orders/add_line", :id => @order.id, :model_id => model_id, :quantity => quantity
    @order = assigns(:order)
  end

  When "the new order is submitted" do
    post "/orders/submit", :id => @order.id
  end

  Then "$size order$s1 exist$s2 for inventory pool $ip" do |size, s1, s2, ip|
    inventory_pool = InventoryPool.find_by_name(ip)
    @submitted_orders = inventory_pool.orders.submitted_orders
    @submitted_orders.size.should == size.to_i
  end

  Then "it asks for $number item$s" do |number, s|
    total = 0
    @submitted_orders.each do |o|
      total += o.lines.collect(&:quantity).sum
    end
    total.should == number.to_i
  end

  
###########################################################################

  When "'$who' searches for '$model'" do |who, model|
    post "/session", :login => who #, :password => "pass"
    post "/models/index", :search => model
    @models = assigns(:models)
  end
  
  Then "he gets an empty result set" do
    @models.empty?.should == true
  end

  Then "he sees '$model'" do |model|
    m = Model.find_by_name(model)
    @models.include?(m).should == true
  end

end