Given "a package '$package' exists" do |package|
  step "a model '#{package}' exists"
  model = Model.find_by_name(package)
  model.is_package = true
  model.save
end

Given "item '$item' is part of package item $package_item" do |item, package_item|
  package = Item.find_by_inventory_code package_item
  item    = Item.find_by_inventory_code item
  item.parent = package
  item.save
end

When /^lending_manager clicks to add an additional model$/ do
  get_via_redirect add_line_backend_inventory_pool_acknowledge_path(@inventory_pool, :start_date => Date.today, :end_date => Date.today)
  #follow_redirect!
end

#Then /^he sees 0 lines 'Khil Remix'$/ do
# the check actually doesn't bother about lines at all...
Then /^(.*) sees (\d*) line(s?) '(.*)'$/ do |who, number, plural, text|
  @response.body.scan(text).size.should == number.to_i
end

Then "even though 'Khil Remix' is not part of a package in inventory pool 2!" do
  # dummy - has comment only!
end
