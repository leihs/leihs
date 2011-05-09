Given "a reservation exists for $quantity '$model' from $from to $to" \
do |quantity, model, from, to|
  model = Model.find_by_name(model)
  order = Factory.create_order({:user_id => Factory.create_user.id})
  order.add_line(quantity.to_i, model, nil, to_date(from), to_date(to))
  order.submit.should == true
  order.lines.size.should >= 1
  model.running_reservations(order.inventory_pool).size.should >= 1
end

Given "a contract exists for $quantity '$model' from $from to $to" \
do |quantity, model, from, to|
  from = to_date(from)
  to   = to_date(to)

  model = Model.find_by_name(model)
  @contract = Factory.create_user.
	              get_current_contract(model.items.first.inventory_pool)
  @contract.add_line(quantity.to_i, model, nil, from, to)
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

# TODO: use $who
Given "the $who signs the contract" do |who|
  @contract.sign
  @contract.save
end

# TODO merge with next step
When "$who checks availability for '$what'" do |who, model|
  @user = User.find_by_login(who)
  @model = Model.find_by_name model
end

# TODO merge with previous step
When "$who checks availability for '$what' on $date" \
do |who, model, date|
  date = to_date(date)
  @user = User.find_by_login(who)
end

Then "it should always be available" do
  @model.availability_changes_in(@inventory_pool).
	 maximum_available_in_period_for_user(@user, Date.today, Availability::ETERNITY).
         should > 0
end

Then "$quantity should be available from $from to $to" do |quantity, from, to|
  from = to_date( from )
  to   = to_date( to )

  @model.availability_changes_in(@inventory_pool).
	 maximum_available_in_period_for_user(@user, from, to).
         should == quantity.to_i
end

Then "the maximum available quantity on $date is $quantity" \
do |date, quantity|
  date = to_date(date)
  @model.availability_changes_in(@inventory_pool).
	 maximum_available_in_period_for_user(@user, date, date).
	 should == quantity.to_i      
end

Then "if I check the maximum available quantity for $date it is $quantity on $current_date" \
do |date, quantity, current_date|
  #tmp#1 test fails because uses current_time argument set in the future
  date = to_date(date)
  back_to_the_future( to_date(current_date) )
  @model.availability_changes_in(@inventory_pool).
	 maximum_available_in_period_for_user(@user, date, date).
	 should == quantity.to_i      
  back_to_the_present
end

Then "the maximum available quantity from $start_date to $end_date is $quantity" \
do |start_date, end_date, quantity|
  start_date = to_date(start_date)
  end_date   = to_date(end_date)
  @model.availability_changes_in(@inventory_pool).
	 maximum_available_in_period_for_user(@user, start_date, end_date).
	 should == quantity.to_i
end

When "I check the availability changes for '$model'" do |model|
  @model = Model.find_by_name model
  visit groups_backend_inventory_pool_model_path(@inventory_pool,@model)
end

Then "$number reservation should show an influence on today's borrowability" \
do |number|
  today = Date.today.strftime("%d.%m.%Y")
  Then "#{to_number(number)} reservations should show an influence on the borrowability on #{today}"
end

# the following is extremely markup structure dependent
Then /^([^ ]*) reservation(.*)? should show an influence on the borrowability on (.*)/ do
|number,plural,date|
  number = to_number(number)

  # find header line, that contains the date
  th = page.first('th', :text => "Borrowable #{date}")
  # parent 'tr' element
  tr_head = th.first(:xpath,'..')
  # next 'tr' element
  tr = tr_head.first(:xpath,'following-sibling::*')
  # all list entries inside that 'tr' element
  tr.all('li').count().should == number
end
