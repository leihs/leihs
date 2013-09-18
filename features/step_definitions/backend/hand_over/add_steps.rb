When /^I add an item to the hand over by providing an inventory code and a date range$/ do
  existing_model_ids = @customer.contracts.unsigned.flat_map(&:models).map(&:id)
  @inventory_code = @current_user.managed_inventory_pools.first.items.in_stock.detect{|i| not existing_model_ids.include?(i.model_id)}.inventory_code unless @inventory_code
  wait_until { find("#code") }
  find("#code").set @inventory_code
  line_amount_before = all(".line").size
  find("#process_helper .button").click
  wait_until(25) { line_amount_before < all(".line").size }
end

Then /^the item is added to the hand over for the provided date range and the inventory code is already assigend$/ do
  @customer.get_current_contract(@ip).items.include?(Item.find_by_inventory_code(@inventory_code)).should == true
  assigned_inventory_codes = all(".line .inventory_code input[type=text]").map(&:value)
  assigned_inventory_codes.should include(@inventory_code)
end

When /^I add an option to the hand over by providing an inventory code and a date range$/ do
  wait_until(15){ all(".loading", :visible => true).empty? }
  @inventory_code = @current_user.managed_inventory_pools.first.options.first.inventory_code
  find("#code").set @inventory_code
  page.execute_script('$("#code").focus()')
  find("#process_helper .button").click
  wait_until(25){ page.evaluate_script("$.active") == 0}
  find(".line .inventory_code", :text => @inventory_code)
  step 'the option is added to the hand over'
end

Then /^the (.*?) is added to the hand over$/ do |type|
  contract = @customer.get_current_contract(@ip)
  case type
  when "option"  
    option = Option.find_by_inventory_code(@inventory_code)
    wait_until(25){ page.evaluate_script("$.active") == 0}
    @option_line = contract.reload.option_lines.where(:option_id => option).first
    contract.reload.options.include?(option).should == true
    find(".option_line .inventory_code", :text => @inventory_code)
  when "model"
    wait_until(25){ page.evaluate_script("$.active") == 0}
    contract.reload.models.include?(@model).should == true
    find(".item_line", :text => @model.name)
  end
end

When /^I add an option to the hand over which is already existing in the selected date range by providing an inventory code$/ do
  2.times do
    step 'I add an option to the hand over by providing an inventory code and a date range'
  end
  wait_until { @option_line.reload.quantity == 2 }
end

Then /^the existing option quantity is increased$/ do
  contract = @customer.get_current_contract(@ip)
  matching_option_lines = contract.option_lines.select{|x| x.option.inventory_code == @inventory_code}
  matching_option_lines.size.should == 1
  all(".option_line.line", :text => @inventory_code).size.should == 1
  matching_option_lines.first.quantity == 2
  all(".option_line.line", :text => @inventory_code).first.find(".quantity input").value.to_i.should == 2
end

When /^I type the beginning of (.*?) name to the add\/assign input field$/ do |type| 
  @target_name = case type
    when "an option"
      @option = @current_user.managed_inventory_pools.first.options.first
      @inventory_code = @option.inventory_code
      @option.name
    when "a model"
      @model = @current_user.managed_inventory_pools.first.items.in_stock.first.model
      @model.name
    when "a template"
      @template = @current_user.managed_inventory_pools.first.templates.first
      @template.name
  end
  wait_until {find("#code")}
  type_into_autocomplete "#code", @target_name[0..(@target_name.size/2)]
end

Then /^I see a list of suggested (.*?) names$/ do |type|
  page.execute_script('$("#code").focus()')
  find(".ui-autocomplete a")
end

When /^I select the (.*?) from the list$/ do |type|
  sleep(1)
  find(".ui-autocomplete a", :text => @target_name).click
end

Then /^each model of the template is added to the hand over for the provided date range$/ do
  @template.models.each do |model|
    @model = model
    step 'the (.*?) is added to the hand over'
  end
end

When /^I add so many lines that I break the maximal quantity of an model$/ do
  @model ||= if @order
    @order.lines.first.model
  else
    @customer.get_current_contract(@ip).lines.first.model
  end
  @target_name = @model.name
  @quantity_added = if @order
    @model.availability_in(@ip).maximum_available_in_period_summed_for_groups @order.lines.first.start_date, @order.lines.first.end_date, @order.user.groups.map(&:id)
  else
    @model.items.size
  end
  (@quantity_added+1).times do
    wait_until {find("#code")}
    type_into_autocomplete "#code", @target_name
    step 'I see a list of suggested model names'
    step 'I select the model from the list'
  end
end

Then /^I see that all lines of that model have availability problems$/ do
  @lines = find(".linegroup", :text => /(Today|Heute)/).all(".item_line", :text => @target_name)
  @lines.each do |line|
    wait_until {
      line.find(".problem.icon")
    } 
  end
end

When /^I add an item to the hand over$/ do
  find("#code").set @item.inventory_code
  page.execute_script('$("#code").focus()')
  find("#process_helper .button").click
  wait_until(25){ page.evaluate_script("$.active") == 0}
end
