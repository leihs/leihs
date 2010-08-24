# Models

When /^I register a new Model '([^']*)'$/ do |model|
  Given "a model '#{model}' exists"
end

# Items in Groups
Then /^that Model should not be available in any other Group$/ do
  pending # express the regexp above with the code you wish you had
  #Then "0 items of that Model should be available in Group '#{@group}' only"
end

Then /^no items of that Model should be (\w*) in any group$/ do |n, plural, state|
  Then "0 items of that Model should be available in Group 'General' only"
end

Then /^(\w+) items of that Model should be (\w*) in Group '([^"]*)'( only)?$/ do |n, state, group, exclusivity|
  n = to_number(n)
  quantities = AvailabilityChanges.maximum_in_state_in_period( @model,
                                                               @inventory_pool,
                                                               @inventory_pool.groups.find_by_name(group),
                                                               DateTime.now,
                                                               (DateTime.now + 10.years),
                                                               AvailableQuantities.status_from(state) )
  puts quantities.inspect
  quantities[group].should == n
end

When /^I move one item of that Model from Group "([^"]*)" to Group "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

# Items

When /^I add (\d+) item(s?) of that Model$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^(\d+) items of that Model in Group "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

# Groups
When /^I add a new Group "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^a Group "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

# Users
Given /^I have a user "([^"]*)" that belongs to Group "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^a user "([^"]*)" that belongs to Group "([^"]*)"$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
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

