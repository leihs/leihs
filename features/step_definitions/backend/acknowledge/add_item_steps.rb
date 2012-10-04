When /^I add a model by typing in the inventory code of an item of that model to the quick add$/ do
  @item = @ip.items.first
  find("#process_helper #code").set @item.inventory_code
  find("#process_helper .button[type=submit]").click
  wait_until {all("#process_helper .loading").size == 0}
end

When /^I start to type the inventory code of an item$/ do
  @item = @ip.items.first
  find("#process_helper").fill_in 'code', :with => @item.inventory_code[0..2] 
end

When /^I wait until the autocompletion is loaded$/ do
  page.execute_script('$("#code").keyup().focus()')
  wait_until(15){ all(".loading", :visible => true).size == 0 and find(".ui-autocomplete") }
end

Then /^I already see possible matches of models$/ do
  page.execute_script('$("#code").keyup().focus()')
  wait_until(10){ all(".loading", :visible => true).size == 0 and find(".ui-autocomplete", :text => @item.model.name) }
end

When /^I select one of the matched models$/ do
  find(".ui-autocomplete").find("a", :text => @item.model.name)
  wait_until { all("#process_helper .loading").size == 0 }
end

Then /^the model is added to the order$/ do
  page.should have_content @item.model.name
  @order.models.include? @item.model
end

When /^I start to type the name of a model$/ do
  @item = @ip.items.first
  find("#process_helper").fill_in 'code', :with => @item.model.name[0..3] 
end

When /^I add a model to the acknowledge which is already existing in the selected date range by providing an inventory code$/ do
  @line = @order.lines.first
  @old_lines_count = @order.lines.count
  @model = @line.model
  @line_el_count = all(".line").size
  find("#process_helper").fill_in 'code', :with => @line.model.items.first.inventory_code
  find("#process_helper button[type=submit]").click
  wait_until { all("#process_helper .loading").size == 0 }
end

Then /^the existing line quantity is not increased$/ do
  old_quantity = @line.quantity 
  @new_quantity = @line.reload.quantity
  @new_quantity.should == old_quantity
end

Then /^an additional line has been created in the backend system$/ do
  @order.lines.reload.count.should == @old_lines_count + 1
end

Then /^the new line is getting visually merged with the existing line$/ do
  all(".line").size.should == @line_el_count
  find(".line", :text => @model.name).find(".amount .selected").text.to_i.should == @new_quantity + 1
end