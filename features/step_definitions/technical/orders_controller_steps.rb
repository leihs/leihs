Given /^test data setup for "Orders controller" feature$/ do
  @lending_manager = @current_user
  @inventory_pool = @lending_manager.inventory_pools.first
end

When /^the index action of the contracts controller is called with the filter parameter "(.*?)"$/ do |arg1|
  response = get manage_contracts_path(@inventory_pool), {status: arg1, format: "json"}
  @json = JSON.parse response.body
end

Then /^the result of this action are all submitted contracts for the given inventory pool$/ do
  @json.each do |contract|
    expect(contract["status"].to_sym).to eq :submitted
  end
end
