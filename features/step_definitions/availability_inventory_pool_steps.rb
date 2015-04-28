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

###########################################################################

# Then /it asks for ([0-9]+) item(s?)$/ do |number, s|
#   total = 0
#   @orders.each do |o|
#     total += o.reservations.sum(:quantity)
#   end
#   expect(total).to eq number.to_i
# end

###########################################################################

Then 'he gets an empty result set' do
  expect(@models_json.empty?).to be true
end

Then "he sees the '$model' model" do |model|
  m = Model.find_by_name(model)
  expect(@models_json.map{|x| x['label']}.include?(m.name)).to be true
end

Then 'all order reservations should be available' do
  reservations = @current_user.reservations.unsubmitted
  expect(reservations.reload.all?{|l| l.available? }).to be true
end

Then(/^these additional order reservations were not created$/) do
  expect(@current_user.orders.first.reservations.reload).to eq @order_lines
end

Then(/^some order reservations were not created$/) do
  expect(@current_user.orders.first.reservations.length).to eq @total_quantity
end
