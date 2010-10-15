Given "$number reservations exist for model '$model'" do |number, model|
end

Given "a reservation exists for $quantity '$model' from $from to $to" \
do |quantity, model, from, to|
  model = Model.find_by_name(model)
  order = Factory.create_order({:user_id => Factory.create_user.id})
  order.add_line(quantity.to_i, model, nil, Factory.parsedate(from),
		                            Factory.parsedate(to))
  order.submit
  order.lines.size.should >= 1
  model.running_reservations(order.inventory_pool).size.should >= 1
end

Given "a contract exists for $quantity '$model' from $from to $to" \
do |quantity, model, from, to|
  model = Model.find_by_name(model)
  @contract = Factory.create_user.
	              get_current_contract(model.items.first.inventory_pool)
  @contract.add_line(quantity.to_i, model, nil, Date.today,
		                                Factory.parsedate(to))
  @contract.save
  line = @contract.item_lines.first
  line.item = model.items.first
  line.save
  @contract.reload
  @contract.lines.size.should >= 1
  @contract.lines.first.item.should_not be_nil
  model.running_reservations(@contract.inventory_pool).size.should >= 1
end


Given "the maintenance period for this model is $days days" do |days|
  @model.maintenance_period = days.to_i
  @model.save
end

Given "$who marks $quantity '$model' as 'in-repair' on 18.3.2100" \
do |who, quantity, model|
  @model = Model.find_by_name(model)
  quantity.to_i.times do |i|
    @model.items[i].is_broken = true
    @model.items[i].is_borrowable = false
    @model.items[i].save
  end
end

Given "$quantity items of this model are for '$level' customers only" \
do |quantity, level|
  items = @model.items
#tmp#9
#  quantity.to_i.times do |i|
#    items[i].required_level = AccessRight::LEVELS[level]
#    items[i].save
#  end
end

# TODO: use $who
Given "the $who signs the contract" do |who|
  @contract.sign
  @contract.save
end

# TODO merge with next step
When "$who checks availability for '$what'" do |who, model|
  @user = User.find_by_login(who)
  inventory_pool = InventoryPool.first
  groups = @user.groups.scoped_by_inventory_pool_id(inventory_pool)
  @periods = @model.availability_changes.in(inventory_pool).
	            available_quantities_for_groups(groups)
end

# TODO merge with previous step
When "$who checks availability for '$what' on $date" \
do |who, model, date|
  date = Factory.parsedate(date)
  @user = User.find_by_login(who)
  inventory_pool = InventoryPool.first
  groups = @user.groups.scoped_by_inventory_pool_id(inventory_pool)
  @periods = @model.availability_changes.in(inventory_pool).
	            between_from_most_recent_start_date(date, date).
		    available_quantities_for_groups(groups)
end

Then "it should always be available" do
  @periods.size.should == 1
  @periods[0].start_date.should <= Date.today
  @periods[0].end_date.should == Availability::ETERNITY
end

Then "$quantity should be available from $from to $to" do |quantity, from, to|
  from = ("now" == from) ? Date.today : Factory.parsedate(from)
  to = ("the_end_of_time" == to) ? Availability::ETERNITY :
	                           Factory.parsedate(to)

  period = get_period(from, to, @periods)
  if period.nil?
    puts ""
    puts "Searching: #{from.day}.#{from.month}.#{from.year}" \
                 " - #{to.day}.#{to.month}.#{to.year}"
    @periods.each do |p|
      puts "   -> #{p.start_date.day}.#{p.start_date.month}.#{p.start_date.year}" \
              " - #{p.end_date.day}.#{p.end_date.month}.#{p.end_date.year} = #{p.quantity}" \
	      unless p.end_date.nil?
    end
  end
  period.should_not be_nil

  period.quantity.should == quantity.to_i
end

Then "the maximum available quantity on $date is $quantity" \
do |date, quantity|
  inventory_pool = InventoryPool.first
  date = Factory.parsedate(date)
  @model.availability_changes.in(inventory_pool).
	 maximum_available_in_period_for_user(@user, date, date).
	 should == quantity.to_i      
end

Then "if I check the maximum available quantity for $date it is $quantity on $current_date" \
do |date, quantity, current_date|
  #tmp#1 test fails because uses current_time argument set in the future
  inventory_pool = InventoryPool.first
  date = Factory.parsedate(date)
  current_date = Factory.parsedate(current_date)
  @model.availability_changes.in(inventory_pool).
	 maximum_available_in_period_for_user(@user, date, date).
	 should == quantity.to_i      
end

Then "the maximum available quantity from $start_date to $end_date is $quantity" \
do |start_date, end_date, quantity|
  start_date = Factory.parsedate(start_date)
  end_date = Factory.parsedate(end_date)
  inventory_pool = InventoryPool.first
  @model.availability_changes.in(inventory_pool).
	 maximum_available_in_period_for_user(@user, start_date, end_date).
	 should == quantity.to_i
end
