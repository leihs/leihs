When /^I click an inventory code input field of an item line$/ do
  @item_line = @customer.contracts.unsigned.last.lines.first
  @item = @item_line.model.items.in_stock.last
  @item_line_element = find(".item_line", match: :first, :text => @item.model.name)
  @item_line_element.find(".inventory_code input").click
end

Then /^I see a list of inventory codes of items that are in stock and matching the model$/ do
  page.should have_selector(".ui-autocomplete", visible: false)
  @item_line_element.find(".ui-autocomplete")
  @item.model.items.in_stock.each do |item|
    @item_line_element.find(".ui-autocomplete").should have_content item.inventory_code
  end
end

When /^I assign an item to the hand over by providing an inventory code and a date range$/ do
  @inventory_code = @current_user.managed_inventory_pools.first.items.in_stock.first.inventory_code unless @inventory_code
  find("#code").set @inventory_code
  line_amount_before = all(".line").size
  assigned_amount_before = all(".line.assigned").size
  find("#process_helper .button").click
  line_amount_before.should == all(".line").size
  assigned_amount_before.should < all(".line.assigned").size
end

When /^I select one of those$/ do
  find(".line[data-id='#{@item_line.id}'] .inventory_code input").click
  step "ensure there are no active requests"
  page.should have_selector(".line[data-id='#{@item_line.id}']")
  @selected_inventory_code = find(".line[data-id='#{@item_line.id}'] .ui-autocomplete", visible: true).first("a .label").text
  find(".line[data-id='#{@item_line.id}'] .ui-autocomplete").first("a").click
  step "ensure there are no active requests"
end

Then /^the item line is assigned to the selected inventory code$/ do
  @item_line.reload.item.inventory_code.should == @selected_inventory_code
end

When /^I select a linegroup$/ do
  find(".linegroup .dates input", match: :first).click
end

When /^I add an item which is matching the model of one of the selected lines to the hand over by providing an inventory code$/ do
  @item = @hand_over.lines.first.model.items.in_stock.first
  find("#code").set @item.inventory_code
  page.execute_script('$("#process_helper").submit()')
end

Then /^the first itemline in the selection matching the provided inventory code is assigned$/ do
  page.should have_selector(".item_line.assigned")
  line = @hand_over.lines.detect{|line| line.item == @item}
  line.should_not == nil
end

Then /^no new line is added to the hand over$/ do
  @hand_over.lines.size.should == @hand_over.reload.lines.size
end

When /^I open a hand over which has multiple lines$/ do
  @ip = @current_user.managed_inventory_pools.first
  @hand_over = @ip.visits.hand_over.detect{|x| x.lines.size > 1}
  @customer = @hand_over.user
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
  within(".item_line.assigned[data-id='#{@item_line.id}']", :text => @item_line.model.name) do
    find(".inventory_code input").value.should == @selected_inventory_code
    find(".inventory_code input").click
    find(".inventory_code input").set ""
    find(:xpath, ".").native.send_key :tab
  end
end

Then /^the assignment of the line to an inventory code is removed$/ do
  page.should have_selector ".notification", text: _("The assignment for %s was removed") % @item_line.model.name, visible: true
  @item_line_element = find(".item_line[data-id='#{@item_line.id}']", :text => @item_line.model.name)
  @item_line_element.find(".inventory_code input").value.should be_empty
  @item_line.reload.item.should be_nil
end
