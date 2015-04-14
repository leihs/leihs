Given /^there are some items$/ do
  3.times do
    FactoryGirl.create :item
  end
end

When /^I search for a text not present anywhere$/ do
  @search_string = "ABC-123-@$!"
  @search_result = Item.search(@search_string)
end

Then /^there are no items found$/ do
  step "there are 0 items found"
end

Then /^there is one item found$/ do
  step "there are 1 items found"
end

Then /^there are (\d+) items found$/ do |n|
  expect(@search_result.count).to eq n.to_i
end

When /^I fetch a random item$/ do
  @fetched_item = Item.order("RAND()").first
end

When /^I store some text as a value to some new property in this item$/ do
  @fetched_item.properties[:mac_address] = @search_string
  @fetched_item.save
end

Then /^I search for the same text I stored$/ do
  @search_result = Item.search(@search_string)
end

Then /^the item found is the one with the new property$/ do
  expect(@search_result.first).to eq @fetched_item
end
