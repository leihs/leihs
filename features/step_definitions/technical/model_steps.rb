Given /^pending cucumber for: All items are available if there are no running reservations$/ do
  pending
  #@models_without_reservations.all? do |model|
  #  InventoryPool.all.all? do |ip|
  #    aq = model.availability_in(ip).changes.select {|x| x.date >= Date.today and x.date <= Date.today }.flat_map(&:quantities)
  #  end
  #end.should be_true
end

Given /^pending cucumber for: All lines are available$/ do
  pending
  #Visit.all.flat_map(&:lines).all?(&:available?).should be_true
end

When /^list of all available models$/ do
  @models = Model.all
  # @models_with_reservations = Visit.all.flat_map{|x| x.lines.flat_map(&:model) }.uniq
  # @models_without_reservations = @all_models - @models_with_reservations
end

When /^list of all users$/ do
  @users = User.all
end

When /^the quantity of items of a user for a specific model is retrieved$/ do
  @quantities_1 = []
  @users.each do |user|
    @models.each do |model|
      @quantities_1 << user.items.where(:model_id => model).count
    end
  end
end

When /^the quantity of items of a model for a specific user is retrieved$/ do
  @quantities_2 = []
  @users.each do |user|
    @models.each do |model|
      @quantities_2 << model.items.where(:inventory_pool_id => user.inventory_pools).count
    end
  end
end

Then /^these quantities must be equal$/ do
  @quantities_1.should eq @quantities_2
end

Given /^pending cucumber for: Total borrowable items$/ do
  pending
  # NOTE: DONT EXPECT THINGS THAT YOU MIGHT KNOW FROM THE PERSONAS !!!
  # HINT: infact they can change !!!
  # model = Model.find {|m| [m.name, m.product].include? "Sharp Beamer" }
  # model.items.count.should == 3
  # model.total_borrowable_items_for_user(@normin).should == 3
end

Given /^pending cucumber for: Scoped by inventory pool$/ do
  pending
end

Given /^pending cucumber for: The maximum quantity available for users$/ do
  pending
end
