When /^'(.*)' orders (\d+) '(.*)' from inventory pool (\d+)( for the same time)?$/ do |who, quantity, model_name, ip, same_time|
  @user = User.find_by_login who
  model = Model.find_by_name(model_name)
  inventory_pool = InventoryPool.find_by_name(ip)

  unless same_time
    @start_date = Date.today + rand(0..3).days
    @end_date = Date.today + rand(3..6).days
  end

  target_contract = @user.reservations_bundles.unsubmitted.find_or_initialize_by(inventory_pool_id: inventory_pool.id)
  model.add_to_contract(target_contract, @user, quantity, @start_date, @end_date)
end

When /^all reservations of '(.*)' are submitted$/ do |who|
  expect(@user.reservations.unsubmitted.reload).not_to be_empty
  @user.reservations_bundles.unsubmitted.each do |reservations_bundle|
    reservations_bundle.submit("this is the required purpose")
  end
  expect(@user.reservations.unsubmitted.reload).to be_empty
end

Then /([0-9]+) order(s?) exist(s?) for inventory pool (.*)/ do |size, s1, s2, ip|
  inventory_pool = InventoryPool.find_by_name(ip)
  @reservations_bundles = inventory_pool.reservations_bundles.submitted.to_a
  expect(@reservations_bundles.size).to eq size.to_i
end

Then /it asks for ([0-9]+) item(s?)$/ do |number, s|
  total = @reservations_bundles.map {|o| o.reservations.sum(:quantity) }.sum
  expect(total).to eq number.to_i
end

When(/^that contract has been deleted$/) do
  expect { @contract.reload }.to raise_error(ActiveRecord::RecordNotFound)
end

Given /^there is a "(.*?)" contract with (\d+) reservations?$/ do |contract_type, no_of_lines|
  @no_of_lines_at_start = no_of_lines.to_i
  status = contract_type.downcase.to_sym

  user = @inventory_pool.users.detect {|u| u.reservations_bundles.where(inventory_pool_id: @inventory_pool, status: status).empty? }
  expect(user).not_to be_nil
  @no_of_lines_at_start.times.map { FactoryGirl.create :reservation, user: user, inventory_pool: @inventory_pool, status: status }
  @contract = user.reservations_bundles.find_by(inventory_pool_id: @inventory_pool, status: status)
end

Given /^there is a "(SIGNED|CLOSED)" contract with reservations?$/ do |contract_type|
  status = contract_type.downcase.to_sym

  @contract = @inventory_pool.reservations_bundles.where(status: status).order("RAND()").first
  @no_of_lines_at_start = @contract.reservations.count
end

When /^one tries to delete a line$/ do
  @result_of_line_removal = @contract.remove_line(@contract.reservations.last)
end

Then /^the amount of reservations decreases by one$/ do
  expect(@contract.reservations.size).to eq(@no_of_lines_at_start - 1)
end

Then /^that line has (.*)(?:\s?)been deleted$/ do |not_specifier|
  expect(@result_of_line_removal).to eq not_specifier.blank?
end

Then /^the amount of reservations remains unchanged$/ do
  expect(@contract.reservations.size).to eq @no_of_lines_at_start
end

Given /^required test data for contract tests existing$/ do
  @inventory_pool = InventoryPool.order('RAND()').detect {|ip| ip.users.customers.exists? and ip.reservations.unsubmitted.exists? and ip.reservations.submitted.exists? }
  @model_with_items = @inventory_pool.items.sample.model
end

Given /^an inventory pool existing$/ do
  @inventory_pool = FactoryGirl.create :inventory_pool
end

Given /^an empty contract of (.*) existing$/ do |allowed_type|
  status = allowed_type.downcase.to_sym
  line = @inventory_pool.reservations.where(status: status).sample
  @contract = line.user.reservations_bundles.find_by(inventory_pool_id: @inventory_pool, status: status)
  @contract.reservations.each &:destroy
  @contract.reservations.reload
end

When /^I add some reservations for this contract$/ do
  @quantity = 3
  expect(@contract.reservations.size).to eq 0
  @contract.add_lines(@quantity, @model_with_items, @user, Date.tomorrow, Date.tomorrow + 1.week)
end

Then /^the size of the contract should increase exactly by the amount of reservations added$/ do
  expect(@contract.reload.reservations.size).to eq @quantity
  expect(@contract.valid?).to be true
end

Given /^an? (submitted|unsubmitted) contract with reservations existing$/ do |arg1|
  User.order('RAND()').detect do |user|
    @contract = user.reservations_bundles.where(status: arg1).sample
  end
end

Given(/^a submitted contract with approvable reservations exists$/) do
  User.all.detect do |user|
    @contract = \
      user
        .reservations_bundles
        .where(status: :submitted)
        .detect { |rb| rb.approvable? }
  end
end

When /^I approve the contract of the borrowing user$/ do
  b = @contract.approve('That will be fine.', true, @current_user)
  expect(b).to be true
  @contract.reservations.each do |reservation|
    expect(reservation.reload.status).to eq :approved
  end
end

Then /^the borrowing user gets one confirmation email$/ do
  @emails = ActionMailer::Base.deliveries
  expect(@emails.count).to eq 1
end

Then /^the subject of the email is "(.*?)"$/ do |arg1|
  expect(@emails[0].subject).to eq '[leihs] Reservation Confirmation'
end

When /^the contract is submitted with the purpose description "(.*?)"$/ do |purpose|
  @purpose = purpose
  @contract.submit(@purpose)
end

Then /^each line associated with the contract must have the same purpose description$/ do
  @contract.reservations.each do |l|
    expect(l.purpose.description).to eq @purpose
  end
end
