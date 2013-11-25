When /^I create an approved contract for "(.*?)"$/ do |name|
  @contract = FactoryGirl.create :contract, :status => :approved, :user => Persona.get(name)
end

Then /^the new contract is empty$/ do
  @contract.lines.size.should == 0
end

When /^I sign the contract$/ do
  @sign_result = @contract.sign(@user)
end

Then /^the contract is approved$/ do
  @sign_result.should be_false
  @contract.status.should == :approved
end

When /^I add a contract line without an assigned item to the new contract$/ do
  @contract.lines << FactoryGirl.create(:contract_line, :contract => @contract)
end

Then /^there isn't any item associated with this contract line$/ do
  @contract.lines.first.item.should be_nil
end
