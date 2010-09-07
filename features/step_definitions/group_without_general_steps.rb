Then /^no items of that Model should be available in any group$/ do
  # will not find any group of that name, which is OK
  # this is an artifact of the olde days when the 'General' group existed...
  Then "0 items of that Model should be available in Group 'NotExistent' only"
end

Then "that Model should not be available to anybody" do
  Then "0 items of that Model should be available in Group 'NotExistent' only"
end

Given /^(\d+) items of that Model in Group "([^"]*)"$/ do |n, group_name|
  Given "#{n} items of model '#{@model.name}' exist"
  When "I assign #{n} items to Group \"#{group_name}\""
end

Given "$n items of that Model should be available to everybody" do |n|
  Availability2::Change.available_for_everybody( @model, @inventory_pool ).should == n.to_i
end

