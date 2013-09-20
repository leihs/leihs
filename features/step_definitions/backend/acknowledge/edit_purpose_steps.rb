Then /^I see the order's purpose$/ do
  page.should have_selector("section.purpose", :text => @order.purpose.description)
end

When /^I change the order's purpose$/ do
  first("section.purpose .button").click
  @new_purpose = "A new purpose"
  first(".dialog #purpose").set @new_purpose
  first(".dialog .button[type=submit]").click
end

Then /^the order's purpose is changed$/ do
  page.should have_selector("section.purpose", :text => @new_purpose)
  @order.reload.purpose.description.should == @new_purpose
end
