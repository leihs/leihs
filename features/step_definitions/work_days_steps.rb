Given "$ip has default workdays" do 
end

Given "inventory_pool is open on $days" do |days|
  inventory_pool = LeihsFactory.create_inventory_pool
  inventory_pool.workday.monday = false
  inventory_pool.workday.tuesday = false
  inventory_pool.workday.wednesday = false
  inventory_pool.workday.thursday = false
  inventory_pool.workday.friday = false
  inventory_pool.workday.saturday = false
  inventory_pool.workday.sunday = false
  inventory_pool.workday.save
  days.split(",").each do |day|
    inventory_pool.workday.update_attributes(day.strip.downcase => true)
  end
end

Given "holidays are from $startdate - $finished because of $reason" do |startdate, finish, reason|
  ip = LeihsFactory.create_inventory_pool
  ip.holidays << Holiday.new(:start_date => LeihsFactory.parsedate(startdate),
                              :end_date => LeihsFactory.parsedate(finish),
                              :name => reason)
  ip.save                                            
end

Given "$date is free because of $reason" do |date, reason|
  ip = LeihsFactory.create_inventory_pool
  ip.holidays << Holiday.new(:start_date => LeihsFactory.parsedate(date),
                              :end_date => LeihsFactory.parsedate(date),
                              :name => reason)
  ip.save
end

Given "today is Sunday $date" do |date|
  @date = date
  Dataset.back_to_date(date.to_date)
end

Given /today is today again/ do
  @date = Date.today
  Dataset.back_to_date
end

When "$who try to order an item for $date" do |who, date|
  inventory_pool, inv_manager, user, model = LeihsFactory.create_dataset_simple

  # Login                            
  post login_path(:login => user.login)
  step "I am logged in as '#{user.login}' with password '#{nil}'"
  @current_user.contract_lines.unsubmitted.delete_all if @contract
  get borrow_root_path
  @response = post borrow_contract_lines_path(:model_id => model.id,
                                              :quantity => 1,
                                              :inventory_pool_id => inventory_pool.id,
                                              :start_date => date,
                                              :end_date => date)
  @contract = @current_user.contracts.unsubmitted.find_by(inventory_pool_id: inventory_pool)
end

# OPTIMIZE 0402
When "$who clicks '$action'" do |who, action|
  @inventory_pool, inv_manager, @user, model = LeihsFactory.create_dataset_simple
  
  #Login as User
  post login_path(:login => inv_manager.login)
  get backend_inventory_pool_hand_over_index_path(@inventory_pool) if action == 'hand over'
  get backend_inventory_pool_workdays_path(@inventory_pool) if action == 'Opening Times'

  #old??# @workday = assigns(:workday)
end

Then "that should be possible$reason" do |reason|
  expect(@contract.lines.size).to eq 1
  line = @contract.lines.first
  line.start_date = LeihsFactory.parsedate(@date)
  expect(line.save).to be true
end

When "trying to set the end date to the same date" do  
  line = @contract.lines.first
  line.end_date = LeihsFactory.parsedate(@date)
  @save_successful = line.save
end

Then "that should not be possible $reason" do
  expect(@save_successful).to be false
end

Then "he sees that his inventory pool is currently open on $days" do |days|
  other_days = Workday::DAYS
  days.split(',').each do |day|
    other_days.delete(day.strip)
    expect(@workday.send(day.strip)).to be true
  end
  
  other_days.each do |day|
#    if @workday.send(day) == true 
#      puts "****************"
#      puts @workday.inspect
#      puts "****************"
#    end
    expect(@workday.send(day)).to be false
  end
end

When "he deselects the following day$s: $days" do |s,days|
  days.split(',').each do |day|
    get close_backend_inventory_pool_workdays_path(@inventory_pool, :day => day.strip)
  end
end

When "he selects the following day$s: $days" do |s,days|
  days.split(',').each do |day|
    get open_backend_inventory_pool_workdays_path(@inventory_pool, :day => day.strip)
  end
end
