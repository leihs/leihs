#
# Models in Groups
#
Then "that model should not be available in any other group"  do
  # FIXME how can be executed the next line ?? where is implemented the maximum method ??
  # quantities = @model.in(@inventory_pool).maximum_available_in_period_for_groups(@inventory_pool.groups.where(['id != ?',@group]).pluck(:id))
  # quantities.values.reduce(:+).to_i.should == 0
end

Then /^(\w+) item(s?) of that model should be available in group '([^"]*)'( only)?$/ do |n, plural, group_name, exclusivity|
  n = to_number(n)
  @group = @inventory_pool.groups.find_by_name(group_name)
  all_groups = [Group::GENERAL_GROUP_ID] + @inventory_pool.group_ids
  quantities = @inventory_pool.partitions_with_generals.hash_for_model(@model)
  quantities[@group.id].to_i.should == to_number(n)

  all_groups.each do |group|
    quantities[group].to_i.should == 0 if (group ? group.name : "General") != group_name
  end if exclusivity
end

# TODO: currently unused
=begin
When /^I move (\w+) item(s?) of that model from group "([^"]*)" to group "([^"]*)"$/ do |n, plural, from_group_name, to_group_name|
  from_group = @inventory_pool.groups.find_by_name from_group_name
  to_group   = @inventory_pool.groups.find_by_name to_group_name
  to_number(n).times do
    Availability::Change.move(@model, from_group, to_group)
  end
end
=end

Then "that model should not be available in any group"  do
  @inventory_pool.partitions_with_generals.hash_for_model(@model).reject { |group_id, num| group_id == Group::GENERAL_GROUP_ID }.size.should == 0
end

# TODO: currently unused
Given /^(\d+) items of that model in group "([^"]*)"$/ do |n, group_name|
  step "#{n} items of model '#{@model.name}' exist"
  step "I assign #{n} items to group \"#{group_name}\""
end

#
# Items
#
When /^I add (\d+) item(s?) of that model$/ do |n, plural|
  step "#{n} items of model '#{@model.name}' exist"
end

When /^an item is assigned to group "([^"]*)"$/ do |to_group_name|
  step "I assign one item to group \"#{to_group_name}\""
end

When /^I assign (\w+) item(s?) to group "([^"]*)"$/ do |n, plural, to_group_name|
  n = to_number(n)
  to_group = @inventory_pool.groups.find_by_name to_group_name
  partition = @inventory_pool.partitions_with_generals.hash_for_model(@model)
  partition[to_group.id] ||= 0
  partition[to_group.id] += n
  @model.partitions.set_in(@inventory_pool, partition)
end

Then "that model should not be available to anybody" do
  step "0 items of that model should be available to everybody"
end

Then "$n items of that model should be available to everybody" do |n|
  User.all.each do |user|
    step "#{n} items of that model should be available to \"#{user.login}\""
  end
end

Then /^(\w+) item(s?) of that model should be available to "([^"]*)"$/ do |n, plural, user|
  @user = User.find_by_login user
  @model.availability_in(@inventory_pool.reload).maximum_available_in_period_for_groups(Date.today, Date.tomorrow, @user.groups).should == n.to_i
end

#
# Groups
#
Given /^a group '([^']*)'( exists)?$/ do |name,foo|
  step "I add a new group \"#{name}\""
end

When /^I add a new group "([^"]*)"$/ do |name|
  @inventory_pool.groups.create(:name => name)
end

# TODO: currently unused
Then /^he must be in group '(\w+)'( in inventory pool )?('[^']*')?$/ \
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

#
# Users
#
Given /^the customer "([^"]*)" is added to group "([^"]*)"$/ do |user, group|
  @user = User.find_by_login user
  @group = @inventory_pool.groups.find_by_name(group)
  @group.users << @user
  @group.save!
end

Given /^a customer "([^"]*)" that belongs to group "([^"]*)"$/ do |user, group|
  step "a customer '#{user}' for inventory pool '#{@inventory_pool.name}'"
  step "the customer \"#{user}\" is added to group \"#{group}\""
end

When /^I lend (\w+) item(s?) of that model to "([^"]*)"$/ do |n, plural, user_login|
  user = User.find_by_login user_login
  @inventory_pool.reload
  n = to_number(n)
  order = FactoryGirl.create :order, :user => user, :inventory_pool => @inventory_pool
  order.add_lines(n, @model, nil, Date.today, Date.tomorrow, @inventory_pool)
  order.submit.should be_true
  order.approve("foo'lish comment").should be_true
  c = Contract.find_by_user_id user
  c.sign(@user)
end

When /^"([^"]*)" returns the item$/ do |user|
  @user = User.find_by_login user
  c = Contract.find_by_user_id @user
  c.close.should be_true
end
