When /^I change the quantity$/ do
  @new_quantity = find("#booking-calendar-quantity").value.to_i + 1
  fill_in "booking-calendar-quantity", with: @new_quantity
end

Then /^the specific line in the summary inside the calendar also updates its quantity$/ do
  find(".modal .line", :text => @edited_line.find("strong", match: :first).text).find("div.col1of10:nth-child(2) > span:nth-child(1)", text: @new_quantity)
end
