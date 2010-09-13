# Models

When /^I register a new Model '([^']*)'$/ do |model|
  Given "a model '#{model}' exists"
end

# Models in Groups
Then "that Model should not be available in any other Group"  do
  quantities = Availability::Change.maximum_available_in_period_for_groups( @model,
                                                                             @inventory_pool,
                                                                             @inventory_pool.groups.find( :all,
                                                                                                          :conditions => ['id != ?',@group]))
  quantities.values.reduce(:+).to_i.should == 0
end

Then /^(\w+) item(s?) of that Model should be available in Group '([^"]*)'( only)?$/ do |n, plural, group_name, exclusivity|
  @group = @inventory_pool.groups.find_by_name(group_name) ## ?? ##
  all_groups = @inventory_pool.groups
  n = to_number(n)
  quantities = Availability::Change.maximum_available_in_period_for_groups( @model,
                                                                             @inventory_pool,
                                                                             all_groups)
  quantities[group_name].to_i.should == n

  if exclusivity
    all_groups.each do |group|
      unless group.name == group_name
        quantities[group.name].should == 0
	puts "yes"
      end
    end
  end
end

When /^I move (\w+) item(s?) of that Model from Group "([^"]*)" to Group "([^"]*)"$/ do |n, plural, from_group_name, to_group_name|
  n = to_number(n)
  from_group = @inventory_pool.groups.find_by_name from_group_name
  to_group   = @inventory_pool.groups.find_by_name to_group_name
  n.times do
    Availability::Change.move(@model, from_group, to_group)
  end
  @inventory_pool.reload
end

# Items

When /^I add (\d+) item(s?) of that Model$/ do |n, plural|
  Given "#{n} items of model '#{@model.name}' exist"
end

# Groups
When /^I add a new Group "([^"]*)"$/ do |name|
  Group.create :inventory_pool_id => @inventory_pool,
	        :name => name
  @inventory_pool.reload
end

Given /^a Group "([^"]*)"$/ do |name|
  When "I add a new Group \"#{name}\""
end

Then /^he must be in Group '(\w+)'( in inventory pool )?('[^']*')?$/ do |group, filler, inventory_pool|
  inventory_pools = []
  if inventory_pool
   inventory_pool.gsub!(/'/,'') # remove quotes
   inventory_pools << InventoryPool.find_by_name( inventory_pool )
  else
    inventory_pools = @user.inventory_pools
  end

  groups = @user.inventory_pools.collect { |ip| ip.groups.scoped_by_name(group).first }
  groups.each do |group|
    group.users.find_by_id( @user.id ).should_not be nil
  end
end

# Users
When "I create a user '$user_name'" do |user|
  @user = Factory.create_user( { :login => user }, { :inventory_pool => @inventory_pool } )
end

Given /^a user "([^"]*)" that belongs to Group "([^"]*)"$/ do |user, group|
  @user = Factory.create_user( { :login => user }, { :inventory_pool => @inventory_pool } )
  @group = @inventory_pool.groups.find_by_name(group)
  @group.users << @user
  @group.save!
end

When /^I lend one item of Model "([^"]*)" to "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^"([^"]*)" returns the item$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^(\d+) item of that Model in the "([^"]*)" Group$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

When /^I lend (\d+) items of that Model to "([^"]*)"$/ do |n, user|
  pending # express the regexp above with the code you wish you had
end

# Inventory Pools
When "I give the user '$user' access to the inventory pool '$inventory_pool'" do |user, inventory_pool|
  @user = User.find_by_login user
  @nventory_pool = InventoryPool.find_by_name inventory_pool
  Factory.define_role( @user, @inventory_pool )
end

When "I remove from user '$user' access to the inventory pool '$inventory_pool'" do |user, inventory_pool|
  pending # express the regexp above with the code you wish you had
end
