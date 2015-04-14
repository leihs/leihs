Given "$number reservations exist for model '$model'" do |number, model|
  # used by "0 reservations exist for model 'NEC 245'"
end

Given "a reservation exists for $quantity '$model' from $from to $to" do |quantity, model, from, to|
  model = Model.find_by_name(model)
  inventory_pool = model.inventory_pools.select{|ip| ip.is_open_on?(to_date(from)) and ip.is_open_on?(to_date(to))}.sample
  user = inventory_pool.users.sample
  @contract_lines = []
  quantity.to_i.times do
    @contract_lines << user.item_lines.create(inventory_pool: inventory_pool,
                                              status: :unsubmitted,
                                              quantity: 1,
                                              model: model,
                                              start_date: to_date(from),
                                              end_date: to_date(to))
  end
  expect(@contract_lines.size).to be >= quantity.to_i
  contract = user.contracts.unsubmitted.find_by(inventory_pool_id: inventory_pool)
  expect(contract.submit("this is the required purpose")).to be true
  expect(model.availability_in(inventory_pool.reload).document_lines.size).to be >= 1
end

Given "a contract exists for $quantity '$model' from $from to $to" do |quantity, model, from, to|
  model = Model.find_by_name(model)
  inventory_pool = model.inventory_pools.order("RAND()").detect {|ip| ip.is_open_on?(to_date(from)) and ip.is_open_on?(to_date(to))}
  user = inventory_pool.users.order("RAND()").first
  purpose = FactoryGirl.create(:purpose)
  @contract_lines = []
  quantity.to_i.times do
    @contract_lines << user.item_lines.create(inventory_pool: inventory_pool,
                                              status: :approved,
                                              quantity: 1,
                                              model: model,
                                              item: model.items.in_stock.where(inventory_pool_id: inventory_pool).order("RAND()").first,
                                              start_date: to_date(from),
                                              end_date: to_date(to),
                                              purpose: purpose)
  end
  expect(@contract_lines.size).to be >= quantity.to_i
  expect(model.availability_in(inventory_pool.reload).document_lines.size).to be >= 1
end


Given "the maintenance period for this model is $days days" do |days|
  @model.maintenance_period = days.to_i
  @model.save
end

Given "$who marks $quantity '$model' as 'in-repair' on 18.3.2030" do |who, quantity, model|
  @model = Model.find_by_name(model)
  quantity.to_i.times do |i|
    @model.items[i].is_broken = true
    @model.items[i].is_borrowable = false
    @model.items[i].save
  end
end

Given "the $who signs the contract" do |who|
  contract_container = @contract_lines.first.user.contracts.approved.find_by(inventory_pool_id: @contract_lines.first.inventory_pool)
  contract = contract_container.sign(User.find_by_login(who), @contract_lines)
  expect(contract.valid?).to be true
  expect(contract.persisted?).to be true
  expect(contract.lines == @contract_lines).to be true
  @contract_lines.each do |line|
    expect(line.status).to eq :signed
  end
end

# TODO merge with next step
When "$who checks availability for '$what'" do |who, model|
  @current_user = User.find_by_login(who)
  @model = Model.find_by_name(model)
end

# TODO merge with previous step
When "$who checks availability for '$what' on $date" do |who, model, date|
  #date = to_date(date)
  @current_user = User.find_by_login(who)
end

Then "it should always be available" do
  expect(@model.availability_in(@inventory_pool).maximum_available_in_period_for_groups(Date.today, Availability::ETERNITY, @user.group_ids)).to be > 0
end

Then "$quantity should be available from $from to $to" do |quantity, from, to|
  from = to_date( from )
  to   = to_date( to )
  expect(@model.availability_in(@inventory_pool).maximum_available_in_period_for_groups(from, to, @user.group_ids)).to eq quantity.to_i
end

Then "the maximum available quantity on $date is $quantity" do |date, quantity|
  date = to_date(date)
  expect(@model.availability_in(@inventory_pool).maximum_available_in_period_for_groups(date, date, @user.group_ids)).to eq quantity.to_i
end

Then "if I check the maximum available quantity for $date it is $quantity on $current_date" do |date, quantity, current_date|
  date = to_date(date)
  Dataset.back_to_date( to_date(current_date) )
  @inventory_pool.reload
  expect(@model.availability_in(@inventory_pool).maximum_available_in_period_for_groups(date, date, @user.group_ids)).to eq quantity.to_i
  Dataset.back_to_date
  @inventory_pool.reload
end

Then "the maximum available quantity from $start_date to $end_date is $quantity" do |start_date, end_date, quantity|
  start_date = to_date(start_date)
  end_date   = to_date(end_date)
  expect(@model.availability_in(@inventory_pool).maximum_available_in_period_for_groups(start_date, end_date, @user.group_ids)).to eq quantity.to_i
end

When "I check the availability changes for '$model'" do |model|
  @model = Model.find_by_name(model)
  # we have a look at the model on purpose, since in the pass this
  # could fail - see 5bd28c92d157220a07dff1ba9a7f43b1fac3f5fd and its fix
  #                  2f160defb39c94d489b0115653be5da4c10519c1
  visit "/manage/#{@inventory_pool.id}/models/#{@model.id}"
  visit groups_backend_inventory_pool_model_path(@inventory_pool,@model)
end

Then "$number reservation should show an influence on today's borrowability" do |number|
  today = I18n.l Date.today
  Then "#{to_number(number)} reservations should show an influence on the borrowability on #{today}"
end

# the following is extremely markup structure dependent
Then /^([^ ]*) reservation(.*)? should show an influence on the borrowability on (.*)/ do |number,plural,date|
  number = to_number(number)

  # find header line, that contains the date
  th = page.first('th', :text => "Borrowable #{date}")
  # parent 'tr' element
  tr_head = th.first(:xpath,'..')
  # next 'tr' element
  tr = tr_head.first(:xpath,'following-sibling::*')
  # all list entries inside that 'tr' element
  expect(tr.all('li').count()).to eq number
end
