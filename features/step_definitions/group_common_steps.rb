# Models

When /^I register a new Model '([^']*)'$/ do |model|
  Given "a model '#{model}' exists"
end

# Models in Groups
Then "that Model should not be available in any other Group"  do
  quantities = @model.in(@inventory_pool).\
	       maximum_available_in_period_for_groups(
		 @inventory_pool.groups.all(:conditions => ['id != ?',@group]))
  quantities.values.reduce(:+).to_i.should == 0
end

Then /^(\w+) item(s?) of that Model should be available in Group '([^"]*)'( only)?$/ do |n, plural, group_name, exclusivity|
  @group = @inventory_pool.groups.find_by_name(group_name)
  all_groups = [Group::GENERAL_GROUP_ID] + @inventory_pool.groups.map(&:id)
  quantities = @model.availability_changes.in(@inventory_pool).current_partition
  quantities[@group.id].to_i.should == to_number(n)

  all_groups.each do |group|
    quantities[group].to_i.should == 0 if (group ? group.name : "General") != group_name
  end if exclusivity
end

When /^I move (\w+) item(s?) of that Model from Group "([^"]*)" to Group "([^"]*)"$/ do |n, plural, from_group_name, to_group_name|
  from_group = @inventory_pool.groups.find_by_name from_group_name
  to_group   = @inventory_pool.groups.find_by_name to_group_name
  to_number(n).times do
    Availability::Change.move(@model, from_group, to_group)
  end
end

Then /^no items of that Model should be available in any group$/ do
  # will not find any group of that name, which is OK
  # this is an artifact of the olde days when the 'General' group existed...
  Then "0 items of that Model should be available in Group 'NotExistent' only"
end

Then "that Model should not be available to anybody" do
  Then "0 items of that Model should be available to everybody"
end

Then "that Model should not be available in any group"  do
  @model.availability_changes.in(@inventory_pool).current_partition.\
	 reject { |group_id, num| group_id == nil }.\
         reduce(:+).to_i.should == 0
end

Given /^(\d+) items of that Model in Group "([^"]*)"$/ do |n, group_name|
  Given "#{n} items of model '#{@model.name}' exist"
  When "I assign #{n} items to Group \"#{group_name}\""
end

# Items

When /^I add (\d+) item(s?) of that Model$/ do |n, plural|
  Given "#{n} items of model '#{@model.name}' exist"
end

When /^I assign (\w+) item(s?) to Group "([^"]*)"$/ do |n, plural, to_group_name|
  n = to_number(n)
  to_group = @inventory_pool.groups.find_by_name to_group_name
  partition = @model.availability_changes.in(@inventory_pool).current_partition
  partition[to_group.id] ||= 0
  partition[to_group.id] += n
  @model.availability_changes.in(@inventory_pool).recompute(partition)
end

Then "$n items of that Model should be available to everybody" do |n|
  User.all.each do |user|
    @model.availability_changes.in(@inventory_pool).
	   maximum_available_in_period_for_user(@user, Date.today, Date.tomorrow ).\
	   should == n.to_i
  end
end

# Groups
When /^I add a new Group "([^"]*)"$/ do |name|
  @inventory_pool.groups.create(:name => name)
end

Given /^a Group "([^"]*)"$/ do |name|
  When "I add a new Group \"#{name}\""
end

Then /^he must be in Group '(\w+)'( in inventory pool )?('[^']*')?$/ \
do |group, filler, inventory_pool|
  inventory_pools = []
  if inventory_pool
    inventory_pool.gsub!(/'/,'') # remove quotes
    inventory_pools << InventoryPool.find_by_name( inventory_pool )
  else
    inventory_pools = @user.inventory_pools
  end

  groups = inventory_pools.collect { |ip| ip.groups.scoped_by_name(group).first }
  groups.each do |group|
    group.users.find_by_id( @user.id ).should_not be nil
  end
end

# Users
When "I create a user '$user_name'" do |user|
  @user = Factory.create_user( { :login => user },
			       { :inventory_pool => @inventory_pool } )
end

Given /^a customer "([^"]*)" that belongs to Group "([^"]*)"$/ do |user, group|
  @user = Factory.create_user( { :login => user },
			       { :role => 'customer',
			         :inventory_pool => @inventory_pool } )
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
When "I give the user '$user' access to the inventory pool '$inventory_pool'" \
do |user, inventory_pool|
  @user = User.find_by_login user
  @nventory_pool = InventoryPool.find_by_name inventory_pool
  Factory.define_role( @user, @inventory_pool )
end

When "I remove from user '$user' access to the inventory pool '$inventory_pool'" \
do |user, inventory_pool|
  pending # express the regexp above with the code you wish you had
end
