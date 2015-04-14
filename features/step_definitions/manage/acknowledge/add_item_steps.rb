When /^I add a model by typing in the inventory code of an item of that model to the quick add$/ do
  @item ||= @current_inventory_pool.items.detect {|x| not x.inventory_code.blank? }
  find("#add-input").set @item.inventory_code
  find("button[type='submit'][title='#{_("Add")}']").click
  find(".line", match: :prefer_exact, :text => @item.model.name)
end

When /^I start to type the inventory code of an item$/ do
  @item = @current_inventory_pool.items.borrowable.order("RAND()").first
  fill_in "add-input", :with => @item.inventory_code[0..3]
end

When /^I wait until the autocompletion is loaded$/ do
  find("#add-input")
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
  expect(@contract.models.include?(@item.model)).to be true
end

When /^I start to type the name of a model( which is not yet in the contract)?$/ do |arg1|
  items = @current_inventory_pool.items.borrowable.order("RAND()")
  @item = if arg1
            items.detect {|i| not @contract.models.include? i.model}
          else
            items.first
          end
  fill_in 'add-input', :with => @item.model.name[0..-2]
end

When /^I add a model to the acknowledge which is already existing in the selected date range by providing an inventory code$/ do
  @line = @contract.lines.order("RAND()").first
  @old_lines_count = @contract.lines.count
  @model = @line.model
  find(".line", match: :prefer_exact, text: @model.name)
  @line_el_count = all(".line").size

  fill_in "add-start-date", with: I18n.l(@line.start_date)
  fill_in "add-end-date", with: I18n.l(@line.end_date)
  fill_in 'add-input', with: @model.items.first.inventory_code

  find("#add-input+button").click
end

Then /^the existing line quantity is not increased$/ do
  old_quantity = @line.quantity 
  expect(@line.reload.quantity).to eq old_quantity
end

Then /^an additional line has been created in the backend system$/ do
  find("#flash")
  expect(@contract.lines.reload.count).to eq @old_lines_count + 1
end

Then /^the new line is getting visually merged with the existing line$/ do
  within "#edit-contract-view #lines" do
    find(".line", match: :prefer_exact, text: @model.name)
    lines = @contract.reload.lines.where(model_id: @model)
    expect(all(".line").count).to eq @line_el_count
    expect(all(".line", text: @model.name).sum{|l| l.find("div:nth-child(3) > span:nth-child(1)").text.to_i}).to eq lines.count
    expect(lines.count).to eq lines.to_a.sum(&:quantity)
  end
end

Given /^I search for a model with default dates and note the current availability$/ do
  init_start_date = Date.parse find("#add-start-date").value
  av = nil
  @model = @current_inventory_pool.models.detect do |model|
    av = model.availability_in(@current_inventory_pool)
    av.changes.keys.last > init_start_date
  end
  @new_start_date = av.changes.select{|k, v| k > init_start_date }.keys.first
  fill_in "add-input", with: @model.name
  find(".ui-menu-item a", match: :prefer_exact, text: @model.name)
  @init_aval = find(".ui-menu-item a", match: :prefer_exact, text: @model.name).find("div.col1of4:nth-child(2) > div:nth-child(1)").text
end

When /^I change the start date$/ do
  fill_in "add-start-date", with: @new_start_date.strftime("%d/%m/%Y")
  find("#add-start-date").click
  find(".ui-state-active").click
end

And /^I change the end date$/ do
  fill_in "add-end-date", with: (@new_start_date + 1).strftime("%d/%m/%Y")
  find("#add-end-date").click
  find(".ui-state-active").click
end

And /^I search again for the same model$/ do
  fill_in "add-input", with: @model.name
end

Then (/^the model's availability has changed$/) do
  @changed_aval = find(".ui-menu-item a", match: :prefer_exact, text: @model.name).find("div.col1of4:nth-child(2) > div:nth-child(1)").text
  expect(@changed_aval.slice(0)).not_to eq @init_aval.slice(0)
end

When(/^I start searching some model for adding it$/) do
  @model = @current_inventory_pool.items.borrowable.order("RAND()").first.model
  find('#add-input').set @model.name[0..-2]
  find('#add-input').click
end

When(/^I leave the autocomplete$/) do
  find('body').click
end

When(/^I reenter the autocomplete$/) do
  find('#add-input').click
end

Then(/^I should still see the model in the resultlist$/) do
  find('.ui-autocomplete a', text: @model.name[0..-2], match: :first)
end

Then(/^only models related to my current pool are suggested$/) do
  if has_selector?(".ui-autocomplete")
    within ".ui-autocomplete" do
      all("li a").each do |x|
        next unless x.find("span.grey-text").text == _("Model")
        name = x.find("strong").text
        expect(@current_inventory_pool.models.include? Model.find_by_name(name)).to be true
      end
    end
  else
    # when selector not present, then no matched results
  end
end

When(/^I enter a model name( which is not related to my current pool)?$/) do |arg1|
  model = if arg1
            Model.order("RAND()") - @current_inventory_pool.models
          else
            Model.order("RAND()")
          end.first
  find('#assign-or-add-input').set model.name[0..-2]
end

