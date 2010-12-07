Given /^a customer "([^"]*)"$/ do |name|
  @user = Factory.create_user({:login => name },
                              {:role => 'customer'})
  r = @user.access_rights.first
  r.save
end

Given /a (\w+) '([^']*)' for inventory pool '([^']*)'$/ do |role,who,ip_name|
  Given "inventory pool '#{ip_name}'"
  @user = Factory.create_user({:login => who},
                              {:role => role,
                              :inventory_pool => @inventory_pool })
  @user.save!
end

Given "a manager '$name' with access level $access_level" do |name,accs_level|
  Given "a manager '#{name}' for inventory pool '#{@inventory_pool.name}'"
  # TODO: very ugly
  ar = @user.access_rights.first
  ar.access_level = accs_level.to_i
  ar.save!
  @user.reload
end

Given "customer '$who' has access to inventory pool $ip_s" do |who, ip_s|
  inventory_pools = ip_s.split(" and ").collect { | ip_name |
    InventoryPool.find_by_name ip_name
  }
  user = Factory.create_user({:login => who}, #, :password => "pass"
			     { :inventory_pool => inventory_pools.first })
  inventory_pools.each { |ip|
    Factory.define_role(user, ip, "customer" )
    user.inventory_pools.include?(ip).should == true
  }
end

