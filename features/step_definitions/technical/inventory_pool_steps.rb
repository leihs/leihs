def make_sure_no_end_date_is_identical_to_any_other!(open_contracts)
  last_date = open_contracts.flat_map(&:contract_lines).map(&:end_date).max { |a, b| a <=> b }
  open_contracts.flat_map(&:contract_lines).each do |cl|
    cl.end_date = last_date
    last_date = cl.end_date.tomorrow
    cl.save
  end
end

def end_first_contract_line_on_same_date_as_second!(contract)
  contract.instance_eval do
    # these two should now be in the same Event
    contract_lines[0].end_date = contract_lines[1].end_date
    contract_lines[0].save
    save
  end
end

def end_third_contract_line_on_different_date!(contract)
  contract.instance_eval do
    # just make sure the third contract_line isn't on the same day
    if contract_lines[2].end_date == contract_lines[1].end_date
      contract_lines[2].end_date = contract_lines[1].end_date.tomorrow
      contract_lines[2].save
    end
    save
  end
end

def start_first_contract_line_on_same_date_as_second!(contract)
  contract.instance_eval do
    # these two should now be in the same Event
    contract_lines[0].start_date = contract_lines[1].start_date
    contract_lines[0].end_date = contract_lines[0].start_date + 2.days
    contract_lines[0].save
    save
  end
end

def start_third_contract_line_on_different_date!(contract)
  contract.instance_eval do
    # just make sure the third contract_line isn't on the same day
    if contract_lines[2].start_date == contract_lines[1].start_date
      contract_lines[2].start_date = contract_lines[1].start_date.tomorrow
      contract_lines[2].end_date = contract_lines[2].start_date + 2.days
      contract_lines[2].save
    end
    save
  end
end

def make_sure_no_start_date_is_identical_to_any_other!(open_contracts)
  previous_date = Date.tomorrow
  open_contracts.flat_map(&:contract_lines).each do |cl|
    cl.start_date = previous_date
    cl.end_date = cl.start_date + 2.days
    previous_date = previous_date.tomorrow
    cl.save
  end
end

Given /^inventory pool model test data setup$/ do
  LeihsFactory.create_default_languages

  # create default inventory_pool
  @current_inventory_pool = LeihsFactory.create_inventory_pool

  User.delete_all

  %W(le_mac eichen_berge birke venger siegfried).each do |login_name|
    LeihsFactory.create_user :login => login_name
  end

  @manager = LeihsFactory.create_user({:login => "hammer"}, {:role => :lending_manager})
end

Given /^all contracts and contract lines are deleted$/ do
  Contract.delete_all
  ContractLine.delete_all
end

Given /^there are open contracts for all users$/ do
  @open_contracts = User.all.map { |user|
    FactoryGirl.create :contract_with_lines, :user => user, :inventory_pool => @current_inventory_pool, :status => :approved
  }
end

Given /^there are open contracts for all users of a specific inventory pool$/ do
  step "there are open contracts for all users"
end

Given /^every contract has a different start date$/ do
  make_sure_no_start_date_is_identical_to_any_other! @open_contracts
end

Given /^there are hand over visits for the specific inventory pool$/ do
  @hand_over_visits = @current_inventory_pool.visits.hand_over
end

When /^all the contract lines of all the events are combined$/ do
  @hand_over_visits.flat_map(&:contract_lines)
end

Then /^the result is a set of contract lines that are associated with the users' contracts$/ do
  expect(@hand_over_visits.count).to eq @open_contracts.flat_map(&:contract_lines).count
end

Given /^there is an open contract with lines for a user$/ do
  @open_contract = FactoryGirl.create :contract_with_lines, :user => User.first, :inventory_pool => @current_inventory_pool, :status => :approved
end

Given /^the first contract line starts on the same date as the second one$/ do
  start_first_contract_line_on_same_date_as_second! @open_contract
end

Given /^the third contract line starts on a different date as the other two$/ do
  start_third_contract_line_on_different_date! @open_contract
end

When /^the visits of the inventory pool are fetched$/ do
  @hand_over_visits = @current_inventory_pool.visits.hand_over
end

Then /^the first two contract lines should now be grouped inside the first visit, which makes it two visits in total$/ do
  expect(@hand_over_visits.count).to eq 2
end

Given /^there are 2 different contracts for 2 different users$/ do
  @open_contract = FactoryGirl.create :contract_with_lines, :user => User.first, :inventory_pool => @current_inventory_pool, :status => :approved, :lines_count => 1
  @open_contract2 = FactoryGirl.create :contract_with_lines, :user => User.last, :inventory_pool => @current_inventory_pool, :status => :approved, :lines_count => 1
end

Given /^there are 2 different contracts with lines for 2 different users$/ do
  @open_contract = FactoryGirl.create :contract_with_lines, :user => User.first, :inventory_pool => @current_inventory_pool, :status => :approved
  @open_contract2 = FactoryGirl.create :contract_with_lines, :user => User.last, :inventory_pool => @current_inventory_pool, :status => :approved
end

Then /^there are 2 hand over visits for the given inventory pool$/ do
  expect(@current_inventory_pool.visits.hand_over.reload.count).to eq 2
end

Then /^there are 2 take back visits for the given inventory pool$/ do
  expect(@current_inventory_pool.visits.take_back.reload.count).to eq 2
end

Given /^1st contract line of 2nd contract has the same start date as the 1st contract line of the 1st contract$/ do
  @open_contract2.contract_lines[0].start_date = @open_contract.contract_lines[0].start_date
  @open_contract2.contract_lines[0].save
end

Given /^1st contract line of 2nd contract has the same end date as the 1st contract line of the 1st contract$/ do
  @open_contract2.contract_lines[0].end_date = @open_contract.contract_lines[0].end_date
  @open_contract2.contract_lines[0].save
end

Given /^1st contract line of 2nd contract has the end date 2 days ahead of its start date$/ do
  @open_contract2.contract_lines[0].end_date = @open_contract2.contract_lines[0].start_date + 2.days
  @open_contract2.contract_lines[0].save
end

Then /^there should be different visits for 2 users with same start and end date$/ do
  expected = if @open_contract2.lines.size > 1 and @open_contract2.lines[0].start_date != @open_contract2.lines[1].start_date
               3
             else
               2
             end
  expect(@current_inventory_pool.visits.hand_over.reload.count).to eq expected
end

Given /^make sure no end date is identical to any other$/ do
  make_sure_no_end_date_is_identical_to_any_other! @open_contracts
end

Given /^to each contract line an item is assigned$/ do
  @open_contracts.each do |c|
    # assign contract lines
    c.contract_lines.each do |cl|
      cl.update_attributes(item: cl.model.items.borrowable.in_stock.first)
    end
  end
end

Given /^all contracts are signed$/ do
  @open_contracts.each do |c|
    # sign the contract
    c.sign(@manager, c.contract_lines)
  end
end

When /^the take back visits of the given inventory pool are fetched$/ do
  @take_back_visits = @current_inventory_pool.visits.take_back
end

Then /^there should be as many events as there are different start dates$/ do
  expect(@take_back_visits.count).to eq @open_contracts.flat_map(&:contract_lines).map(&:end_date).uniq.count
end

When /^all the contract lines of all the visits are combined$/ do
  @take_back_lines = @take_back_visits.flat_map(&:contract_lines)
end

Then /^one should get the set of contract lines that are associated with the users' contracts$/ do
  expect(@take_back_lines.count).to eq @open_contracts.flat_map(&:contract_lines).count
end

Given /^1st contract line ends on the same date as 2nd$/ do
  end_first_contract_line_on_same_date_as_second! @open_contract
end

Given /^3rd contract line ends on a different date than the other two$/ do
  end_third_contract_line_on_different_date! @open_contract
end

Then /^the first 2 contract lines should be grouped inside the 1st visit, which makes it two visits in total$/ do
  expect(@take_back_visits.count).to eq 2
end

Given /^to each contract line of the user's contract an item is assigned$/ do
  @open_contract.contract_lines.each do |cl|
    cl.update_attributes(item: cl.model.items.borrowable.in_stock.first)
  end
end

Given /^the contract is signed$/ do
  @open_contract.sign(@manager, @open_contract.contract_lines)
end

Given /^to each contract line of both contracts an item is assigned$/ do
  [@open_contract, @open_contract2].each do |c|
    # assign contract lines
    c.contract_lines.each do |cl|
      cl.update_attributes(item: cl.model.items.borrowable.in_stock.first)
    end
  end
end

Given /^both contracts are signed$/ do
  [@open_contract, @open_contract2].each do |c|
    # sign the contract
    c.sign(@manager, c.contract_lines)
  end
end

Then /^the first 2 contract lines should now be grouped inside the 1st visit, which makes it 2 visits in total$/ do
  expect(@take_back_visits.count).to eq 2
end

Given(/^a maximum amount of visits is defined for a week day$/) do
  @inventory_pool = @current_user.inventory_pools.shuffle.detect { |ip| not ip.workday.max_visits.empty? }
  expect(@inventory_pool).not_to be_nil
end

Then(/^the amount of visits includes$/) do |table|
  date = @inventory_pool.potential_visits.sample.date
  total_visits = table.raw.flatten.sum do |k|
    case k
      when "potential hand overs (not yet acknowledged orders)"
        @inventory_pool.potential_visits.select{|v| v.date == date}.size
      when "hand overs"
        @inventory_pool.visits.hand_over.where(date: date).size
      when "take backs"
        @inventory_pool.visits.take_back.where(date: date).size
    end
  end
  expect(@inventory_pool.workday.total_visits_by_date[date].size).to eq total_visits
end
