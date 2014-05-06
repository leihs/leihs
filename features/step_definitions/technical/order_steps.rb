Given /there is (only )?a contract by (a customer named )?'(.*)'/ do | only, bla, who |
  step "there are no contracts" if only
  firstname, lastname = who
  firstname, lastname = who.split(" ") if who.include?(" ")
  
  if @inventory_pool
    @user = LeihsFactory.create_user( { :login => who, :firstname => firstname, :lastname => lastname }, { :inventory_pool => @inventory_pool } )
    @contract = FactoryGirl.create(:contract, :user => @user, :inventory_pool => @inventory_pool)
  else
    @user = LeihsFactory.create_user(:login => who, :firstname => firstname, :lastname => lastname)
    @contract = FactoryGirl.create(:contract, :user => @user)
  end
end

# TODO perform real post 
When "'$who' places a new contract" do | who |
  step "there is a contract by '#{who}'"
  post login_path(:login => who)
end

Given "the contract was submitted" do
  @contract.submit
  @contract.status.should == :submitted
end

When "he submits the new contract" do
  @contract = @current_user.get_unsubmitted_contract
  @contract.status.should == :unsubmitted
  post borrow_contract_path(purpose: "this is the required purpose")
  @contract = @contract.reload
  @contract.status.should == :submitted
end

Given "there are only $total contracts" do | total |
  total.to_i.times do | i |
    user = LeihsFactory.create_user(:login => "user_#{i}")
    contract = FactoryGirl.create(:contract, :user => user).submit
  end
end

Given "the list of submitted contracts contains $total elements" do | total |
  Contract.submitted.count.should == 0
  user = LeihsFactory.create_user
  total.to_i.times { FactoryGirl.create(:contract, :user => user).submit }
  Contract.submitted.count.should == total.to_i
end

Given "there are no contracts" do
  Order.destroy_all
end

Given "there are no contracts" do
  Contract.destroy_all
end

Given "there are no new contracts" do
  Order.delete_all :status => :submitted
end

Given /it asks for ([0-9]+) item(s?) of model '(.*)'/ do |number, plural, model|
  @contract.add_lines(number, Model.find {|m| [m.name, m.product].include? model }, @user)
  @contract.log_history("user submits contract", 1)
  @contract.save
  @contract.has_changes?.should == false
  @contract.contract_lines[0].model.name.should == model
end

When "he asks for another $number items of model '$model'" do |number, model|
	Given "it asks for #{number} items of model '#{model}'"
end

When "$who chooses one contract" do | who |
  contract = @contracts.first
  get manage_edit_contract_path(@inventory_pool, contract)
  response.should render_template('backend/acknowledge/show')
  #old??# @contract = assigns(:contract)
end

When "I choose to process $who's contract" do | who |
  el = page.first(:xpath, "//tr[contains(.,'#{who}')]")
  el.click_link("View and edit")
end

Then "$name's contract is shown" do |who|
  # body =~ /.*Order.*Joe.*/
  page.should have_xpath("//body[contains(.,'#{who}')][contains(.,'Order')]")
end

###############################################

# TODO test as Given 
When "$who asks for $quantity '$what' from $from" do | who, quantity, what, from |
  from = Date.today.strftime("%d.%m.%Y") if from == "today"
  quantity.times do
    @contract.contract_lines << FactoryGirl.create(:contract_line,
                                                   :model_name => what,
                                                   :start_date => from)
  end
  @contract.save
end


#When "$who approves contract" do |who|
#  @comment ||= ""
#  @contract.approvable?.should be_true
##0402  post login_path(:login => @last_manager_login_name)
#  post manage_approve_contract_path(@inventory_pool, @contract, :comment => @comment)
#  @contract = assigns(:contract)
#  @contract.should_not be_nil
#  @contract.approvable?.should be_false
#  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
#  @response = response
#end

When "$who rejects contract" do |who|
  @comment ||= ""
  post reject_backend_inventory_pool_acknowledge_path(@inventory_pool, @contract, :comment => @comment)
  #old??# @contract = assigns(:contract)
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end


When "he deletes contract" do
  @contract = @user.get_unsubmitted_contract
  delete backend_inventory_pool_acknowledge_path(@inventory_pool, @contract)
  response.redirect_url.should == "http://www.example.com/backend/inventory_pools/#{@inventory_pool.id}/acknowledge"
end

When "'$who' contracts $quantity '$model'" do |who, quantity, model|
  post login_path(:login => who)
  step "I am logged in as '#{who}' with password '#{nil}'"
  get borrow_root_path
  model_id = Model.find {|m| [m.name, m.product].include? model }.id
  post borrow_contract_lines_path(:model_id => model_id, :quantity => quantity, :inventory_pool_id => @inventory_pool.id)
  @contract_lines = @current_user.contracts.first.lines
end

When "'$user' contracts another $quantity '$model' for the same time" do |user, quantity, model|
  model_id = Model.find {|m| [m.name, m.product].include? model }.id
  post borrow_contract_lines_path(:model_id => model_id, :quantity => quantity, :inventory_pool_id => @inventory_pool.id)
  #old??# @contract = assigns(:contract)
end

When "'$who' contracts $quantity '$model' from inventory pool $ip" do |who, quantity, model, ip|
  post login_path(:login => who)
  step "I am logged in as '#{who}' with password '#{nil}'"
  get borrow_root_path
  model_id = Model.find {|m| [m.name, m.product].include? model }.id
  inv_pool = InventoryPool.find_by_name(ip)
  post borrow_contract_lines_path(:model_id => model_id, :quantity => quantity, :inventory_pool_id => inv_pool.id)
  @contract = @current_user.get_unsubmitted_contract

  @total_quantity ||= 0
  available_items_in_ip = inv_pool.own_items.length
  quantity_i = quantity.to_i
  @total_quantity += quantity_i if quantity_i <= available_items_in_ip
end

When "'$who' searches for '$model' on frontend" do |who, model|
  post login_path(:login => who)
  response = get search_path(:term => model, :format => :json)
  @models_json = JSON.parse(response.body)
end

Then /([0-9]+) contract(s?) exist(s?) for inventory pool (.*)/ do |size, s1, s2, ip|
  inventory_pool = InventoryPool.find_by_name(ip)
  @contracts = inventory_pool.contracts.submitted
  @contracts.size.should == size.to_i
end

Then "customer '$user' gets notified that his contract has been submitted" do |who|
  user = LeihsFactory.create_user({:login => who })
  user.notifications.size.should == 1
  user.notifications.first.title = "Order submitted"
end

Then "the contract was placed by a customer named '$name'" do | name |
  page.first(".table-overview .fresh").should have_content(name)
end

When(/^the contract is deleted$/) do
  lambda {@contract.reload}.should raise_error(ActiveRecord::RecordNotFound)
end

Given /^there is a "(.*?)" contract with (\d+) lines?$/ do |contract_type, no_of_lines|
  # FIXME before testing these 2 status, we need to improve our factories, adapting them to our validations
  pending if [:signed, :closed].include? contract_type.downcase.to_sym

  @no_of_lines_at_start = no_of_lines.to_i
  @contract = FactoryGirl.create :contract_with_lines, :status => contract_type.downcase.to_sym, :inventory_pool => @inventory_pool, :lines_count => @no_of_lines_at_start
end

When /^one tries to delete a line$/ do
  @result_of_line_removal = @contract.remove_line(@contract.lines.last, FactoryGirl.create(:user).id)
end

Then /^the amount of lines decreases by one$/ do
  @contract.lines.size.should eq(@no_of_lines_at_start - 1)
end

Then /^the line is (.*)(?:\s?)deleted$/ do |not_specifier|
  @result_of_line_removal.should (not_specifier.blank? ? be_true : be_false)
end

Then /^the amount of lines remains unchanged$/ do
  @contract.lines.size.should eq @no_of_lines_at_start
end

Given /^required test data for contract tests existing$/ do
  @inventory_pool = FactoryGirl.create :inventory_pool
  @model_with_items = FactoryGirl.create :model_with_items
end

Given /^an inventory pool existing$/ do
  @inventory_pool = FactoryGirl.create :inventory_pool
end

Given /^an empty contract of (.*) existing$/ do |allowed_type|
  @contract = FactoryGirl.create :contract, :status => allowed_type.downcase.to_sym, :inventory_pool => @inventory_pool
end

When /^I add some lines for this contract$/ do
  @quantity = 3
  @contract.lines.size.should == 0
  @contract.add_lines(@quantity, @model_with_items, @user, Date.tomorrow, Date.tomorrow + 1.week)
end

Then /^the size of the contract should increase exactly by the amount of lines added$/ do
  @contract.reload.lines.size.should == @quantity
  @contract.valid?.should be_true
end

Given /^an unsubmitted contract with lines existing$/ do
  @contract = FactoryGirl.create :contract_with_lines, :status => :unsubmitted, :inventory_pool => @inventory_pool
end

Given /^a submitted contract with lines existing$/ do
  @contract = FactoryGirl.create :contract_with_lines, :status => :submitted, :inventory_pool => @inventory_pool
end

Given /^a borrowing user existing$/ do
  @borrowing_user = LeihsFactory.create_user({:login => 'foo', :email => 'foo@example.com'}, {:password => 'barbarbar'})
end

When /^I approve the contract of the borrowing user$/ do
  @contract.approve("That will be fine.", Persona::get("Ramon"))
  @contract.status.should == :approved
end

Then /^the borrowing user gets one confirmation email$/ do
  @emails = ActionMailer::Base.deliveries
  @emails.count.should == 1
end

Then /^the subject of the email is "(.*?)"$/ do |arg1|
  @emails[0].subject.should == "[leihs] Reservation Confirmation"
end

When /^the contract is submitted with the purpose description "(.*?)"$/ do |purpose|
  @purpose = purpose
  @contract.submit(@purpose)
end

Then /^each line associated with the contract must have the same purpose description$/ do
  @contract.lines.each do |l|
    l.purpose.description.should == @purpose
  end
end
