Then /^I see the order's purpose$/ do
  find("section.purpose", :text => @order.purpose)
end

When /^I change the order's purpose$/ do
  find("section.purpose .button").click
  wait_until { find(".dialog #purpose") }
  @new_purpose = "A new purpose"
  find(".dialog #purpose").set @new_purpose
  find(".dialog .button[type=submit]").click
  wait_until{ all(".dialog .loading").size == 0 }
end

Then /^the order's purpose is changed$/ do
  @order.reload.purpose.should == @new_purpose
  find("section.purpose", :text => @order.purpose)
end