Given 'this model has $number item$s in inventory pool $ip' do |number, s, ip|
  inventory_pool = InventoryPool.find_by_name(ip)
  number.to_i.times do | i |
    FactoryGirl.create(:item, owner: inventory_pool, model: @model)
  end
  expect(inventory_pool.items.where(model_id: @model.id).count).to eq number.to_i
end

Then "the maximum number of available '$model' for '$who' is $size" do |model, who, size|
  user = User.find_by_login(who)
  @model = Model.find_by_name(model)
  expect(user.items.where(model_id: @model.id).count).to eq size.to_i
end

Then 'he gets an empty result set' do
  expect(@models_json.empty?).to be true
end

Then "he sees the '$model' model" do |model|
  m = Model.find_by_name(model)
  expect(@models_json.map{|x| x['label']}.include?(m.name)).to be true
end

Then /^this user has (\d+) unsubmitted reservations, which (\d+) are available$/ do |all_n, available_n|
  reservations = @user.reservations.unsubmitted
  expect(reservations.size).to eq all_n.to_i
  reservations = reservations.select &:available?
  expect(reservations.size).to eq available_n.to_i
end

Then(/^some order reservations were not created$/) do
  expect(@user.reservations.length).to eq @total_quantity
end
