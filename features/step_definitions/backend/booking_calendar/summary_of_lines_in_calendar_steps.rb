When /^I change the quantity$/ do
  @new_quantity = 1+find("#quantity").value.to_i
  find("#quantity").set(@new_quantity)
end

Then /^the specific line in the summary inside the calendar also updates its quantity$/ do
  wait_until do
    find(".dialog .line", :text => @edited_line.find(".name").text).find(".requested .number").text.to_i == @new_quantity
  end
end