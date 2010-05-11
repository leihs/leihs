###############################################
# Inventory Pools

Given "inventory pool '$name'" do | inventory_pool_name |
  @inventory_pool = Factory.create_inventory_pool :name => inventory_pool_name
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
    Factory.create_item(:model_id => model_id)
  end
end

Given /^item(s?) (\S+) of model '(.+)' exist(s?)( only)?$/ \
do |plural, inventory_codes, model, plural2, only|
  Item.delete_all if only
  inv_codes = inventory_codes.split /,/
  model_id = Model.find_by_name(model).id
  inv_codes.each do | inv_code |
    Factory.create_item(:model_id => model_id, :inventory_code => inv_code)
  end
end

Given "$number items of this model exist" do |number|
  number.to_i.times do | i |
    Factory.create_item(:model_id => @model.id)
  end
  @model = Model.find(@model.id)
end
