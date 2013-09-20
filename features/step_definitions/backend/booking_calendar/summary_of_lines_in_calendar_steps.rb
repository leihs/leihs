When /^I change the quantity$/ do
  @new_quantity = find("#quantity").value.to_i + 1
  fill_in "quantity", with: @new_quantity
end

Then /^the specific line in the summary inside the calendar also updates its quantity$/ do
  step "ensure there are no active requests"
  find(".dialog .line", :text => @edited_line.first(".name").text).first(".requested .number").text.to_i.should == @new_quantity
end