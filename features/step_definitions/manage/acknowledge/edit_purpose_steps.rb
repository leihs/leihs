Then /^I see the contract's purpose$/ do
  find("#purpose", :text => @contract.purpose.description)
end

When /^I change the contract's purpose$/ do
  find("#edit-purpose").click
  @new_purpose = "A new purpose"
  find(".modal textarea[name='purpose']").set @new_purpose
  find(".modal .button[type=submit]").click
end

Then /^the contract's purpose is changed$/ do
  find("#purpose", :text => @new_purpose)
  @contract.reload.purpose.description.should == @new_purpose
end
