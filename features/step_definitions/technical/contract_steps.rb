When /^I create an approved contract for "(.*?)"$/ do |name|
  user = User.where(:login => name.downcase).first
  FactoryGirl.create :access_right, user: user, inventory_pool: @current_inventory_pool
  @contract = FactoryGirl.create :contract,
                                 status: :approved,
                                 inventory_pool: @current_inventory_pool,
                                 user: user
end

Then /^the new contract is empty$/ do
  expect(@contract.lines.size).to eq 0
end

When /^I sign the contract$/ do
  @sign_result = @contract.sign(@user)
end

Then /^the contract is approved$/ do
  expect(@sign_result).to be false
  expect(@contract.status).to eq :approved
end

When /^I add a contract line without an assigned item to the new contract$/ do
  @contract.lines << FactoryGirl.create(:contract_line, :contract => @contract)
end

Then /^there isn't any item associated with this contract line$/ do
  expect(@contract.lines.first.item).to eq nil
end
