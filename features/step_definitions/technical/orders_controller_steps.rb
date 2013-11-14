Given /^test data setup for "Orders controller" feature$/ do
  @lending_manager = @current_user
  @inventory_pool = @lending_manager.inventory_pools.first
end

When /^the index action of the orders controller is called with the filter parameter "(.*?)"$/ do |arg1|
  response = get manage_contracts_path(@inventory_pool), {filter: "pending", format: "json"}
  @json = JSON.parse response.body
end

Then /^the result of this action are all submitted\/pending orders for the given inventory pool$/ do
  @json.each do |order|
    order["lines"].each do |line|
      OrderLine.find_by_id(line["id"].to_i).order.status.should == :submitted
    end
  end
end
