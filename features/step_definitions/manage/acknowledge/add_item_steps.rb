When /^I add a model by typing in the inventory code of an item of that model to the quick add$/ do
  @item ||= @ip.items.detect {|x| not x.inventory_code.blank? }
  find("#add-input").set @item.inventory_code
  find("button[type='submit'][title='#{_("Add")}']").click
end

When /^I start to type the inventory code of an item$/ do
  @item = @ip.items.borrowable.sample
  fill_in "add-input", :with => @item.inventory_code[0..3]
end

When /^I wait until the autocompletion is loaded$/ do
  find("#add-input")
  page.execute_script('$("#add-input").change().blur().focus().change()')
  find(".ui-autocomplete", match: :first)
end

Then /^I already see possible matches of models$/ do
  find("#add-input").click
  find(".ui-autocomplete", match: :first, :text => @item.model.name)
end

When /^I select one of the matched models$/ do
  find(".ui-autocomplete a[title='#{@item.model.name}']", :text => @item.model.name).click
end

Then /^the model is added to the contract$/ do
  find(".line", text: @item.model.name)
  @contract.models.include?(@item.model).should be_true
end

When /^I start to type the name of a model$/ do
  @item = @ip.items.borrowable.sample
  fill_in 'add-input', :with => @item.model.name[0..7]
end

When /^I add a model to the acknowledge which is already existing in the selected date range by providing an inventory code$/ do
  @line = @contract.lines.sample
  @old_lines_count = @contract.lines.count
  @model = @line.model
  find(".line", match: :prefer_exact, text: @model.name)
  @line_el_count = all(".line").size
  fill_in 'add-input', :with => @model.items.first.inventory_code
  sleep 0.3
  find("#add-input+button").click
end

Then /^the existing line quantity is not increased$/ do
  old_quantity = @line.quantity 
  @line.reload.quantity.should == old_quantity
end

Then /^an additional line has been created in the backend system$/ do
  find("#flash")
  @contract.lines.reload.count.should == @old_lines_count + 1
end

Then /^the new line is getting visually merged with the existing line$/ do
  find(".line", match: :prefer_exact, text: @model.name).should have_content @contract.lines.where(:model_id => @model.id).sum(&:quantity)
  sleep(0.66)
  all(".line").count.should == @line_el_count
  find(".line", match: :prefer_exact, text: @model.name).find("div:nth-child(3) > span:nth-child(1)").text.to_i.should == @contract.reload.lines.select{|l| l.model == @model}.size
end

Given /^I search for a model with default dates and note the current availability$/ do
  av = nil
  @model = @current_inventory_pool.models.detect do |model|
    av = model.availability_in(@current_inventory_pool)
    av.changes.keys.size > 1
  end

  total_quantity_in_ip = @current_inventory_pool.items.borrowable.select{|i| i.model == @model}.count
  @new_start_date = av.changes.select{|k, v| v.values.any? {|v| v[:in_quantity] < total_quantity_in_ip }}.keys.first

  fill_in "add-input", with: @model.name
  find("a.ui-corner-all", match: :first)
  @init_aval = find("a.ui-corner-all", match: :prefer_exact, text: @model.name).find("div.col1of4:nth-child(2) > div:nth-child(1)").text
end

When /^I change the start date$/ do
  fill_in "add-start-date", with: @new_start_date.strftime("%d.%m.%Y")
  find("#add-start-date").click
  find(".ui-state-active").click
end

And /^I change the end date$/ do
  fill_in "add-end-date", with: (@new_start_date + 1).strftime("%d.%m.%Y")
  find("#add-end-date").click
  find(".ui-state-active").click
end

And /^I search again for the same model$/ do
  fill_in "add-input", with: @model.name
end

Then (/^the model's availability has changed$/) do
  sleep(0.66)
  @changed_aval = find("a.ui-corner-all", match: :prefer_exact, text: @model.name).find("div.col1of4:nth-child(2) > div:nth-child(1)").text
  @changed_aval.slice(0).should_not == @init_aval.slice(0)
end

When(/^I start searching some model for adding it$/) do
  @model = @current_inventory_pool.items.borrowable.map(&:model).sample
  find('#add-input').set @model.name[0..2]
  find('#add-input').click
end

When(/^I leave the autocomplete$/) do
  find('body').click
end

When(/^I reenter the autocomplete$/) do
  find('#add-input').click
end

Then(/^I should still see the model in the resultlist$/) do
  find('.ui-autocomplete a', text: @model.name[0..2], match: :first)
end
