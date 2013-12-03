Given /^a model that has capacities for a group and group general$/ do
  pending
end

Given /^a user that is in that group$/ do
  pending
end

When /^the user contracts the sum of his group and group general$/ do
  pending
end

Then /^this contract should be allocated in the group and the group general$/ do
  pending
end

Then /^the quantity should be available for that contract$/ do
  pending
end

Given /^a list of changes\/availabilities$/ do
  @ip = @current_user.managed_inventory_pools.first
  @model = @ip.models.max {|a,b| a.availability_in(@ip).changes.length <=> b.availability_in(@ip).changes.length}
  @reference = @model.availability_in(@ip).available_total_quantities
end

When /^I request that list multiple times the allocation of the lines should always be the same$/ do
  50.times do
    @reference.to_json.should == @model.availability_in(@ip).available_total_quantities.to_json
  end
end
