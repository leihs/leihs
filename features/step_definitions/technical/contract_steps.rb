When /^I create an approved contract for "(.*?)" with a contract line without an assigned item$/ do |name|
  user = User.where(:login => name.downcase).first
  FactoryGirl.create :access_right, user: user, inventory_pool: @current_inventory_pool

  contract = user.contracts.approved.find_by(inventory_pool_id: @current_inventory_pool)
  expect(contract).to be_nil

  @contract_line = FactoryGirl.create :contract_line,
                                      status: :approved,
                                      inventory_pool: @current_inventory_pool,
                                      user: user

  @contract = user.contracts.approved.find_by(inventory_pool_id: @current_inventory_pool)
  expect(@contract.lines.count).to eq 1
end

When /^I sign the contract$/ do
  @contract.sign(@current_user, @contract.lines)
end

Then /^the contract is still approved$/ do
  expect(@contract_line.reload.status).to eq :approved
end

Then /^there isn't any item associated with this contract line$/ do
  expect(@contract_line.item).to be_nil
end
