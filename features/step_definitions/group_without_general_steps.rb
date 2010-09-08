Then /^no items of that Model should be available in any group$/ do
  # will not find any group of that name, which is OK
  # this is an artifact of the olde days when the 'General' group existed...
  Then "0 items of that Model should be available in Group 'NotExistent' only"
end

Then "that Model should not be available to anybody" do
  Then "0 items of that Model should be available in Group 'NotExistent' only"
end

Then "that Model should not be available in any Group"  do
  quantities = Availability2::Change.maximum_available_in_period_for_groups( @model,
                                                                             @inventory_pool,
                                                                             @inventory_pool.groups.all)
  quantities.values.reduce(:+).to_i.should == 0
end

Given /^(\d+) items of that Model in Group "([^"]*)"$/ do |n, group_name|
  Given "#{n} items of model '#{@model.name}' exist"
  When "I assign #{n} items to Group \"#{group_name}\""
end

When /^I assign (\w+) item(s?) to Group "([^"]*)"$/ do |n, plural, to_group_name|
  n = to_number(n)
  to_group = @inventory_pool.groups.find_by_name to_group_name
  partitions = Availability2::Change.partitions(@model, @inventory_pool)
  partitions[Group::GENERAL_GROUP_ID] = partitions[Group::GENERAL_GROUP_ID] - n
  partitions[to_group.id] += n
  Availability2::Change.new_partition(@model, partitions)
  @inventory_pool.reload
end

Given "$n items of that Model should be available to everybody" do |n|
  Availability2::Change.available_for_everybody( @model, @inventory_pool ).should == n.to_i
end

