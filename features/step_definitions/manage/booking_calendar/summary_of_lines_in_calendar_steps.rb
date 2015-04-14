When /^I change the quantity( of the model in the calendar which leads to an overbooking)?$/ do |arg1|
  n = if arg1
        @line.model.items.where(inventory_pool_id: @line.inventory_pool).count
      else
        1
      end
  @new_quantity = find("#booking-calendar-quantity").value.to_i + n
  fill_in "booking-calendar-quantity", with: @new_quantity
end

Then /^the specific line in the summary inside the calendar also updates its quantity$/ do
  find(".modal .line", :text => @edited_line.find("strong", match: :first).text).find("div.col1of10:nth-child(2) > span:nth-child(1)", text: @new_quantity)
end
