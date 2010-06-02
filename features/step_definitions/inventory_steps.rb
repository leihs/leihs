###############################################
# Inventory Pools

Given "inventory pool '$inventory_pool_name'" do | inventory_pool_name |
  @inventory_pool = Factory.create_inventory_pool :name => inventory_pool_name
end

Given "inventory pool short name '$shortname'" do | shortname |
  @inventory_pool.shortname = shortname
  puts @inventory_pool.save
end

# Allow switching of the default inventory pool on which we are acting
Given "we are using inventory pool '$inventory_pool' for now" do |inventory_pool_name|
  @inventory_pool = InventoryPool.find_by_name inventory_pool_name
end

Given /^(\d+) inventory pool(s?)$/ do | size, plural |
  InventoryPool.delete_all
  size.to_i.times do |i|
    Factory.create_inventory_pool(:name => (i+1))
  end
  @inventory_pools = InventoryPool.all
  @inventory_pools.size.should == size.to_i
  # default inventory pool
  @inventory_pool = InventoryPool.first
end

###############################################
# Categories

Given "a category '$category' exists" do | category |
  Factory.create_category(:name => category)
end  
  
Given "the category '$category' is child of '$parent' with label '$label'" do | category, parent, label |
  c = Category.find(:first, :conditions => {:name => category})
  p = Category.find(:first, :conditions => {:name => parent})
  c.parents << p
  c.set_label(p, label)
end

When "the category '$category' is selected" do | category|
  @category = Category.find(:first, :conditions => {:name => category})
end

Then "there are $d_size direct children and $t_size total children" do | d_size, t_size | 
  @category.children.size.should == d_size.to_i
  @category.children.recursive.to_a.size.should == t_size.to_i
end

Then "the label of the direct children are '$labels'" do | labels |
  @category_labels = [] 
  @category.children.each do |c|
    @category_labels << c.label(@category)
  end
  labels.split(',').each do |l|
    @category_labels.include?(l).should == true
  end
end

###############################################
# Models

Given "a model '$model' exists" do | model |
  @model = Factory.create_model(:name => model)
end
  
Given "the model '$model' belongs to the category '$category'" do |model, category|
  @model = Model.find(:first, :conditions => {:name => model})
  @model.categories << Category.find(:first, :conditions => {:name => category})    
end

When "the model '$model' is selected" do | model|
  @model = Model.find(:first, :conditions => {:name => model})
end
 
Then "there are $size models belonging to that category" do |size|
  @category.models.size.should == size.to_i
end


###############################################
# Items

#Given "$number items of model '$model' exist" do |number, model|
Given /(\d+) item(s?) of model '(.+)' exist(s?)/ do |number, plural1, model, plural2|
  model_id = Model.find_by_name(model).id
  number.to_i.times do | i |
    Factory.create_item( :model_id => model_id, :inventory_pool => @inventory_pool )
  end
end

Given /^item(s?) '(\S*)' of model '(.+)' exist(s?)( only)?$/ \
do |plural, inventory_codes, model, plural2, only|
  Item.delete_all if only
  inv_codes = inventory_codes.split /,/
  model_id = Model.find_by_name(model).id
  inv_codes.each do | inv_code |
    Factory.create_item(:model_id => model_id, :inventory_code => inv_code,
		        :inventory_pool => @inventory_pool )
  end
end

Given "$number items of this model exist" do |number|
  number.to_i.times do | i |
    Factory.create_item( :model_id => @model.id, :inventory_pool => @inventory_pool )
  end
  @model = Model.find(@model.id)
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

Then "the generated_code should look like this $result" do |result|
  @inventory_code.should == result
end

