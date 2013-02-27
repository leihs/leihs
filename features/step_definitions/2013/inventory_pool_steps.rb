def make_sure_no_start_date_is_identical_to_any_other!(open_contracts)
  previous_date = Date.tomorrow
  open_contracts.flat_map(&:contract_lines).each do |cl|
    cl.start_date = previous_date  
    cl.end_date   = cl.start_date + 2.days 
    previous_date = previous_date.tomorrow
    cl.save
  end
end

Given /^inventory pool model test data setup$/ do
  LeihsFactory.create_default_languages

  # create default inventory_pool
  @ip = LeihsFactory.create_inventory_pool

  User.delete_all

  %W(le_mac eichen_berge birke venger siegfried).each do |login_name|
    LeihsFactory.create_user :login => login_name
  end

  @manager = LeihsFactory.create_user({:login => "hammer"}, {:role  => "manager"} )
end

Given /^there are open contracts for all users of a specific inventory pool$/ do
  @open_contracts = User.all.map do |user|
    FactoryGirl.create :contract_with_lines, :user => user, :inventory_pool => @ip
  end
end

Given /^every contract has a different start date$/ do
  make_sure_no_start_date_is_identical_to_any_other! @open_contracts
end

Given /^there are hand over visits for the specific inventory pool$/ do
  @hand_over_visits = @ip.visits.hand_over
end

When /^all the contract lines of all the events are combined$/ do
  @hand_over_visits.flat_map(&:contract_lines)
end

Then /^the result is a set of contract lines that are associated with the users' contracts$/ do
  @hand_over_visits.count.should eq @open_contracts.flat_map(&:contract_lines).count
end

