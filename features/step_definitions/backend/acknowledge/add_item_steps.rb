When /^I add a model by typing in the inventory code of an item of that model to the quick add$/ do
  @item = @ip.items.first
  find("#add_item #quick_add").set @item.inventory_code
  find("#add_item .button[type=submit]").click
  wait_until {all("#add_item .loading").size == 0}
end

When /^I start to type the inventory code of an item$/ do
  @item = @ip.items.first
  find("#add_item").fill_in 'code', :with => @item.inventory_code[0..2] 
end

When /^I wait until the autocompletion is loaded$/ do
  page.execute_script('$("#quick_add").focus()')
  wait_until(10){ all("#add_item .loading").size == 0 and find(".ui-autocomplete") }
end

Then /^I already see possible matches of models$/ do
  page.execute_script('$("#quick_add").focus()')
  find(".ui-autocomplete").should have_content @item.model.name
end

When /^I select one of the matched models$/ do
  find(".ui-autocomplete").find("a", :text => @item.model.name)
  wait_until { all("#add_item .loading").size == 0 }
end

Then /^the model is added to the order$/ do
  page.should have_content @item.model.name
  @order.models.include? @item.model
end

When /^I start to type the name of a model$/ do
  @item = @ip.items.first
  find("#add_item").fill_in 'code', :with => @item.model.name[0..3] 
end

When /^I add a model to the hand over which is already existing in the selected date range by providing an inventory code$/ do
  @line = @order.lines.first
  @model = @line.model
  find("#add_item").fill_in 'code', :with => @line.model.items.first.inventory_code
  find("#add_item button[type=submit]").click
  wait_until { all("#add_item .loading").size == 0 }
end

Then /^the existing line quantity is increased$/ do
  old_quantity = @line.quantity 
  @line.reload.quantity.should == old_quantity+1
  find(".line", :text => @model.name).find(".amount .selected").text.to_i.should == @line.reload.quantity
end