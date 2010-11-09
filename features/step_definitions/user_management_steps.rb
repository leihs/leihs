Given /^a customer "([^"]*)"$/ do |name|
  @user = Factory.create_user({:login => name
                              }, {:role => 'customer'})
  r = @user.access_rights.first
  r.save
end

Given "user '$who' has access to inventory pool $ip_s" do |who, ip_s|
  inventory_pools = ip_s.split(" and ").collect { | ip_name |
    InventoryPool.find_by_name ip_name
  }
  user = Factory.create_user({:login => who
                          #, :password => "pass"
                             },
			     { :inventory_pool => inventory_pools.first })
  inventory_pools.each { |ip|
    Factory.define_role(user, ip, "customer" )
    user.inventory_pools.include?(ip).should == true
  }
end

