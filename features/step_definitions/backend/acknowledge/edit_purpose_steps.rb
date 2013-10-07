Then /^I see the contract's purpose$/ do
  page.should have_selector("section.purpose", :text => @contract.purpose.description)
end

When /^I change the contract's purpose$/ do
  first("section.purpose .button").click
  @new_purpose = "A new purpose"
  first(".dialog #purpose").set @new_purpose
  first(".dialog .button[type=submit]").click
end

Then /^the contract's purpose is changed$/ do
  page.should have_selector("section.purpose", :text => @new_purpose)
  @contract.reload.purpose.description.should == @new_purpose
end
