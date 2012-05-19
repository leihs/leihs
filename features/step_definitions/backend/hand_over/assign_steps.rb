When /^I click an inventory code input field of an item line$/ do
  @item_line = @customer.contracts.unsigned.last.lines.first
  @item = @item_line.model.items.in_stock.last
  @item_line_element = find(".item_line", :text => @item.model.name)
  @item_line_element.find(".inventory_code input").click
  page.execute_script("$('.line[data-id=#{@item_line.id}] .inventory_code input').focus()")
end

Then /^I see a list of inventory codes of items that are in stock and matching the model$/ do
  find(".ui-autocomplete")
  @item.model.items do |item|
    find(".ui-autocomplete").should have_content item.inventory_code
  end
end

When /^I select one of those$/ do
  page.execute_script("$('.line[data-id=#{@item_line.id}] .inventory_code input').focus()")
  wait_until { find(".ui-autocomplete a") }
  first_element = find(".ui-autocomplete a")
  @selected_inventory_code = first_element.find(".label").text
  first_element.click
  wait_until { all(".loading", :visible => true).size == 0 }
end

Then /^the item line is assigned to the selected inventory code$/ do
  @item_line.reload.item.inventory_code.should == @selected_inventory_code
end

When /^I select a linegroup$/ do
  find(".linegroup .dates input").click
end

When /^I add an item which is matching the model of one of the selected lines to the hand over by providing an inventory code$/ do
  @item = @hand_over.lines.first.model.items.in_stock.first
  find("#code").set @item.inventory_code
  page.execute_script('$("#process_helper").submit()')
  wait_until { all(".loading", :visible => true).size == 0 }
end

Then /^the first itemline in the selection matching the provided inventory code is assigned$/ do
  line = @hand_over.lines.detect{|line| line.item == @item}
  line.should_not == nil
  find(".item_line.assigned")
end

Then /^no new line is added to the hand over$/ do
  @hand_over.lines.size.should == @hand_over.reload.lines.size
end

When /^I open a hand over which has multiple lines$/ do
  @ip = @user.managed_inventory_pools.first
  @customer = @ip.users.all.detect do |user| 
    user.contracts.unsigned.detect do |contract| 
      contract.lines.size > 1
    end
  end
  @hand_over = @customer.visits.hand_over.detect{|x| x.lines.size > 1}
  visit backend_inventory_pool_user_hand_over_path(@ip, @customer)
  page.has_css?("#hand_over", :visible => true)
end

When /^I open a hand over with lines that have assigned inventory codes$/ do
  steps %Q{
    When I open a hand over
     And I click an inventory code input field of an item line
    Then I see a list of inventory codes of items that are in stock and matching the model
    When I select one of those
    Then the item line is assigned to the selected inventory code 
  }
end

When /^I clean the inventory code of one of the lines$/ do
  @item_line_element.find(".inventory_code input").click
  @item_line_element.find(".inventory_code input").set ""
  @item_line_element.click
end

Then /^the assignment of the line to an inventory code is removed$/ do
  binding.pry
end
