Given "this model has $number item$s in inventory pool $ip" do |number, s, ip|
  inventory_pool = InventoryPool.find_by_name(ip)
  number.to_i.times do | i |
    FactoryGirl.create(:item, :owner => inventory_pool, :model => @model)
  end
  inventory_pool.items.where(:model_id => @model.id).count.should == number.to_i
end

Then "the maximum number of available '$model' for '$who' is $size" do |model, who, size|
  user = User.find_by_login(who)
  @model = Model.find_by_name(model)
  user.items.where(:model_id => @model.id).count.should == size.to_i
end

###########################################################################

Then /it asks for ([0-9]+) item(s?)$/ do |number, s|
  total = 0
  @orders.each do |o|
    total += o.lines.sum(:quantity)
  end
  total.should == number.to_i
end

###########################################################################

Then "he gets an empty result set" do
  @models_json.empty?.should be_true
end

Then "he sees the '$model' model" do |model|
  m = Model.find_by_name(model)
  @models_json.map{|x| x["label"]}.include?(m.name).should be_true
end

Then "all order lines should be available" do
  @order = @current_user.get_current_order
  @order.order_lines.reload.all?{|l| l.available? }.should be_true
end

Then(/^these additional order lines were not created$/) do
  @current_user.orders.first.lines.reload.should == @order_lines
end

Then(/^some order lines were not created$/) do
  @current_user.orders.first.lines.length.should == @total_quantity
end
