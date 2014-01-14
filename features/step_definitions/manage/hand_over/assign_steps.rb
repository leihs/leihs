When /^I click an inventory code input field of an item line$/ do
  @item_line = @customer.contracts.approved.last.lines.first
  #@item = @item_line.model.items.in_stock.last
  #@item_line_element = find(".line", match: :prefer_exact, :text => @item.model.name)
  @item_line_element = find(".line", match: :prefer_exact, :text => @item_line.model.name)
  @item_line_element.find("[data-assign-item]").click
end

Then /^I see a list of inventory codes of items that are in stock and matching the model$/ do
  within @item_line_element.find(".ui-autocomplete") do
    @item_line.model.items.in_stock.each do |item|
      find("a", text: item.inventory_code)
    end
  end
end

When /^I assign an item to the hand over by providing an inventory code and a date range$/ do
  @inventory_code = @current_user.managed_inventory_pools.first.items.in_stock.first.inventory_code unless @inventory_code
  find("[data-add-contract-line]").set @inventory_code
  line_amount_before = all(".line").count
  assigned_amount_before = all(".line [data-assign-item][disabled]").count
  find("[data-add-contract-line] + .addon").click
  find("input[data-assign-item][value='#{@inventory_code}']")
  sleep(0.88)
  line_amount_before.should == all(".line").count
  assigned_amount_before.should < all(".line [data-assign-item][disabled]").count
end

When /^I select one of those$/ do
  unless @item_line.is_a? OptionLine                  # assign inventory code applies only to items
    within(".line[data-id='#{@item_line.id}']") do
      find("input[data-assign-item]").click
      x = find(".ui-autocomplete a", match: :first)
      @selected_inventory_code = x.find("strong", match: :first).text
      x.click
    end
  end
end

Then /^the item line is assigned to the selected inventory code$/ do
  visit current_path
  @item_line.reload.item.inventory_code.should == @selected_inventory_code
end

When /^I select a linegroup$/ do
  find("[data-selected-lines-container] input[data-select-lines]", match: :first).click
end

When /^I add an item which is matching the model of one of the selected unassigned lines to the hand over by providing an inventory code$/ do
  selected_ids = all(".line [data-select-line]:checked").map {|cb| cb.find(:xpath, "ancestor::div[@data-id]")["data-id"]}
  @item = @hand_over.lines.select{|l| !l.item and selected_ids.include? l.id.to_s and l.model.items.in_stock.exists?}.first.model.items.in_stock.first
  find("[data-add-contract-line]").set @item.inventory_code
  find("[data-add-contract-line] + .addon").click
end

Then /^the first itemline in the selection matching the provided inventory code is assigned$/ do
  page.should have_selector(".line.green")
  line = @hand_over.reload.lines.detect{|line| line.item == @item}
  line.should_not == nil
end

Then /^no new line is added to the hand over$/ do
  @hand_over.lines.size.should == @hand_over.reload.lines.size
end

When /^I open a hand over which has multiple lines$/ do
  @ip = @current_user.managed_inventory_pools.first
  @hand_over = @ip.visits.hand_over.detect{|x| x.lines.size > 1}
  @customer = @hand_over.user
  visit manage_hand_over_path(@ip, @customer)
  page.has_css?("#hand-over-view", :visible => true)
end

When /^I open a hand over which has multiple unassigned lines$/ do
  @ip = @current_user.managed_inventory_pools.first
  @hand_over = @ip.visits.hand_over.detect{|x| x.lines.select{|l| !l.item}.count >= 2}
  @customer = @hand_over.user
  visit manage_hand_over_path(@ip, @customer)
  page.has_css?("#hand-over-view", :visible => true)
end

When /^I open a hand over which has multiple unassigned lines and models in stock$/ do
  @ip = @current_user.managed_inventory_pools.first
  @models_in_stock = @ip.items.by_responsible_or_owner_as_fallback(@ip).in_stock.map(&:model).uniq
  @hand_over = @ip.visits.hand_over.detect{|v| v.lines.select{|l| !l.item and @models_in_stock.include? l.model}.count >= 2}
  @customer = @hand_over.user
  visit manage_hand_over_path(@ip, @customer)
  page.has_css?("#hand-over-view", :visible => true)
end

When /^I open a hand over with lines that have assigned inventory codes$/ do
  steps %Q{
    When I open a hand over which has multiple unassigned lines and models in stock
     And I click an inventory code input field of an item line
    Then I see a list of inventory codes of items that are in stock and matching the model
    When I select one of those
    Then the item line is assigned to the selected inventory code 
  }
end

When /^I clean the inventory code of one of the lines$/ do
  within(".line[data-line-type='item_line'][data-id='#{@item_line.id}']") do
    find(".col4of10 strong", text: @item_line.model.name)
    find("[data-assign-item][disabled]").value.should == @selected_inventory_code
    find("[data-remove-assignment]").click
  end
end

Then /^the assignment of the line to an inventory code is removed$/ do
  find(".notice", text: _("The assignment for %s was removed") % @item_line.model.name)
  within(".line[data-line-type='item_line'][data-id='#{@item_line.id}']", :text => @item_line.model.name) do
    find("[data-assign-item]").value.should be_empty
  end
  @item_line.reload.item.should be_nil
end
