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
  back_to_the_future(date.to_date)
end

Given /today is today again/ do
  @date = Date.today
  back_to_the_present
end

When "$who try to order an item for $date" do |who, date|
  inventory_pool, inv_manager, user, model = LeihsFactory.create_dataset_simple

  # Login                            
  post "/session", :login => user.login
  step "I am logged in as '#{user.login}' with password '#{nil}'"
  @order.destroy if @order
  get '/order'
  post add_line_order_path( :model_id => model.id,
                            :quantity => 1,
                            :inventory_pool_id => inventory_pool.id,
                            :start_date => date,
                            :end_date => date)
                           
  @order = @current_user.get_current_order
  @line = @order.order_lines.last
end

# OPTIMIZE 0402
When "$who clicks '$action'" do |who, action|
  @inventory_pool, inv_manager, @user, model = LeihsFactory.create_dataset_simple
  
  #Login as User
  post "/session", :login => inv_manager.login
  get backend_inventory_pool_hand_over_index_path(@inventory_pool) if action == 'hand over'
  get backend_inventory_pool_workdays_path(@inventory_pool) if action == 'Opening Times'

  #old??# @workday = assigns(:workday)
end

Then "that should be possible$reason" do |reason|
  @contract.lines.size.should == 1
  line = @contract.lines.first
  line.start_date = LeihsFactory.parsedate(@date)
  line.save.should == true
end

When "trying to set the end date to the same date" do  
  line = @contract.lines.first
  line.end_date = LeihsFactory.parsedate(@date)
  @save_successful = line.save
end

Then "that should not be possible $reason" do
  @save_successful.should == false
end

Then "he sees that his inventory pool is currently open on $days" do |days|
  other_days = Workday::DAYS
  days.split(',').each do |day|
    other_days.delete(day.strip)
    @workday.send(day.strip).should == true
  end
  
  other_days.each do |day|
#    if @workday.send(day) == true 
#      puts "****************"
#      puts @workday.inspect
#      puts "****************"
#    end
    @workday.send(day).should == false
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
