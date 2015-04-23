Given /^a list of changes\/availabilities$/ do
  @model = @current_inventory_pool.models.max {|a,b| a.availability_in(@current_inventory_pool).changes.length <=> b.availability_in(@current_inventory_pool).changes.length}
  @reference = @model.availability_in(@current_inventory_pool).available_total_quantities
end

When /^I request that list multiple times the allocation of the reservations should always be the same$/ do
  50.times do
    expect(@reference.to_json).to eq @model.availability_in(@current_inventory_pool).available_total_quantities.to_json
  end
end
