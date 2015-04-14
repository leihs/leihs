###############################################
# Inventory Pools

Given "inventory pool '$inventory_pool_name'" do | inventory_pool_name |
  @inventory_pool = LeihsFactory.create_inventory_pool :name => inventory_pool_name
end

Given "inventory pool short name '$shortname'" do | shortname |
  @inventory_pool.shortname = shortname
  @inventory_pool.save
end

# Allow switching of the default inventory pool on which we are acting
Given "we are using inventory pool '$inventory_pool' for now" do |inventory_pool_name|
  @inventory_pool = InventoryPool.find_by_name inventory_pool_name
end

Given /^(\d+) inventory pool(s?)$/ do | size, plural |
  InventoryPool.delete_all
  size.to_i.times do |i|
    LeihsFactory.create_inventory_pool(:name => (i+1))
  end
  @inventory_pools = InventoryPool.all
  expect(@inventory_pools.size).to eq size.to_i
  # default inventory pool
  @inventory_pool = InventoryPool.first
end

###############################################
# Locations

Given "a location in building '$building' room '$room' and shelf '$shelf' exists" do | building_name, room, shelf |
  building = FactoryGirl.create(:building, name: building_name)
  @location = FactoryGirl.create(:location, building: building, room: room, shelf: shelf)
end
  
###############################################
# Categories

Given "a category '$category' exists" do | category |
  LeihsFactory.create_category(:name => category)
end  
  
Given "the category '$category' is child of '$parent' with label '$label'" do | category, parent, label |
  c = Category.where(:name => category).first
  p = Category.where(:name => parent).first
  c.set_parent_with_label(p, label)
end

When "the category '$category' is selected" do |category|
  @category = Category.where(:name => category).first
end

Then "there are $d_size direct children and $t_size total children" do | d_size, t_size | 
  expect(@category.children.size).to eq d_size.to_i
  expect(@category.descendants.size).to eq t_size.to_i
end

Then "the label of the direct children are '$labels'" do | labels |
  @category_labels = @category.children.map {|c| c.label(@category.id) }
  labels.split(',').each do |l|
    expect(@category_labels.include?(l)).to be true
  end
end

###############################################
# Models

Given "a model '$model' exists" do | model |
  @model = LeihsFactory.create_model(:product => model)
end

When /^I register a new model '([^']*)'$/ do |model|
  step "a model '#{model}' exists"
end
  
Given "the model '$model' belongs to the category '$category'" do |model, category|
  @model = Model.find_by_name(model)
  @model.categories << Category.where(:name => category).first    
end

When "the model '$model' is selected" do | model|
  @model = Model.find_by_name(model)
  end
 
Then "there are $size models belonging to that category" do |size|
  expect(@category.models.size).to eq size.to_i
end


###############################################
# Items

#Given "$number items of model '$model' exist" do |number, model|
Given /(\d+) item(s?) of model '(.+)' exist(s?)/ do |number, plural1, model, plural2|
  @model = LeihsFactory.create_model(:product => model)
  number.to_i.times do | i |
    FactoryGirl.create(:item, :owner => @inventory_pool, :model => @model)
  end
end

Given /^(a?n? ?)item(s?) '([^']*)' of model '([^']*)' exist(s?)( only)?$/ do |particle,plural, inventory_codes, model, plural2, only|
  Item.delete_all if only

  @model = LeihsFactory.create_model(:product => model)

  inv_codes = inventory_codes.split /,/
  inv_codes.each do | inv_code |
    FactoryGirl.create(:item, :owner => @inventory_pool, :model => @model, :inventory_code => inv_code)
  end
end

Given "at that location resides an item '$item' of model '$model'" do |item, model|
  step "an item '#{item}' of model '#{model}' exists"
  our_item = Item.find_by_inventory_code(item)
  our_item.location = @location
  our_item.save!
end

Given "$number items of this model exist" do |number|
  number.to_i.times do | i |
    FactoryGirl.create(:item, :owner => @inventory_pool, :model => @model)
  end
  @model = Model.find(@model.id)
end

Given /^(\w+) item(s?) of that model exist(s?)/ \
do |number, plural, plural2|
  number = to_number(number)
  step "#{number} items of this model exist"
end

Given "we have items with the following inventory_codes:" do |inventory_codes_table|
  inventory_codes_table.hashes.each do |hash|
    FactoryGirl.create(:item, :owner => @inventory_pool, :model => @model, :inventory_code => hash[:inventory_code] )
  end
end

When "the broken alorithm proposes wrongly a duplicate inventory code '$code'" do |code|
  Item.class_exec(code) do |code|
    eval "
      class << self
        alias_method :proposed_inventory_code_orig, :proposed_inventory_code
        def proposed_inventory_code(inventory)
	  '#{code}'
        end
      end
    "
  end
end

When "the lending_manager creates a new package" do
  post_via_redirect update_package_backend_inventory_pool_models_path( @inventory_pool, :model => { :name => "Crappodile" } )
end

Then "we need to fix the algorithm again so subsequent tests won't fail" do
  Item.class_eval do
    class << self
      alias_method :proposed_inventory_code, :proposed_inventory_code_orig
    end
  end
end

When "leihs generates a new inventory code" do
  @inventory_code = Item.proposed_inventory_code(@inventory_pool)
end

Then "the generated_code should look like this '$result'" do |result|
  expect(@inventory_code).to eq result
end

When "we add an item '$inventory_code'" do |inventory_code|
  FactoryGirl.create(:item, :owner => @inventory_pool, :model => @model, :inventory_code => inventory_code )
end

# this test is specifically for the 'New Item' page
# Then /^the item should( only)? be assignable to the '([^']*)' departement$/ do |only,name|
#   within "#item_inventory_pool_id" do
#     options = all("option")
#     if only
#       expect(options.size).to eq 1
#     else
#       expect(options.size).to be > 1
#     end
#     expect(options.detect { |option| option.text == name }).not_to be_nil
#   end
# end

# Customers
# When "I give the customer '$user' access to the inventory pool '$inventory_pool'" do |user, inventory_pool|
#   @user = User.find_by_login user
#   @nventory_pool = InventoryPool.find_by_name inventory_pool
#   LeihsFactory.define_role( @user, @inventory_pool )
# end
