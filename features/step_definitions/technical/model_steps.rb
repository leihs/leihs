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
  expect(@quantities_1).to eq @quantities_2
end
