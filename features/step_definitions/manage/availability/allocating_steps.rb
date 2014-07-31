Given /^a list of changes\/availabilities$/ do
  @ip = @current_user.managed_inventory_pools.first
  @model = @ip.models.max {|a,b| a.availability_in(@ip).changes.length <=> b.availability_in(@ip).changes.length}
  @reference = @model.availability_in(@ip).available_total_quantities
end

When /^I request that list multiple times the allocation of the lines should always be the same$/ do
  50.times do
    expect(@reference.to_json).to eq @model.availability_in(@ip).available_total_quantities.to_json
  end
end
