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

# When /^lending_manager clicks to add an additional model$/ do
#   get_via_redirect add_line_backend_inventory_pool_acknowledge_path(@inventory_pool, start_date: Date.today, end_date: Date.today)
#   #follow_redirect!
# end

#Then /^he sees 0 reservations 'Khil Remix'$/ do
# the check actually doesn't bother about reservations at all...
Then /^(.*) sees (\d*) line(s?) '(.*)'$/ do |who, number, plural, text|
  expect(@response.body.scan(text).size).to eq number.to_i
end

Then "even though 'Khil Remix' is not part of a package in inventory pool 2!" do
  # dummy - has comment only!
end

Given(/^this model is a package$/) do
  @model.update_attributes(is_package: true)
end

Given(/^this package item is part of this package model$/) do
  @item.model = @model
  @item.save
  expect(@item.reload.model).to eq @model
  expect(@model.items.include?(@item)).to be true
  @package_item = @item
end

Given(/^this item is part of this package item$/) do
  @item.parent = @package_item
  @item.save
  expect(@item.reload.parent).to eq @package_item
  expect(@package_item.children.include?(@item)).to be true
end
