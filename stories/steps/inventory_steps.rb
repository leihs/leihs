steps_for(:inventory) do

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
# Packages

  Given "a package '$package' exists" do | package |
    package = Factory.create_package(:name => package)
  end

  Given "the package '$package' has $size model$s '$model'" do |package, size, s, model|
    p = Package.find(:first, :conditions => {:name => package})
    m = Model.find(:first, :conditions => {:name => model})
    p.model_links << ModelLink.create(:model => m, :quantity => size.to_i)
  end

  When "the package '$package' is selected" do | package |
    @package = Package.find(:first, :conditions => {:name => package})
  end
 
  Then "there are $size models belonging to that package with total quantity as $quantity" do |size, quantity|
    @package.models.size.should == size.to_i
    @package.total_quantity.should == quantity.to_i
  end

###############################################
# Items

  Given "$number items of model '$model' exist" do |number, model|
    number.to_i.times do | i |
      Factory.create_item(:model_id => Model.find_by_name(model).id)
    end
  end


###############################################
# Packages

  Given "a package '$name' exists" do |name|
    @package = Factory.create_package(:name => name)
  end
  
  Given "the package contains $quantity '$model'" do |quantity, model|
   quantity.to_i.times { @package.models << Model.find(:first, :conditions => {:name => model}) }
  end


end