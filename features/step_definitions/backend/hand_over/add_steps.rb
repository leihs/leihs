When /^I add an item to the hand over by providing an inventory code and a date range$/ do
  binding.pry
  @inventory_code = @user.managed_inventory_pools.first.items.in_stock.first.inventory_code
  find("#code").set @inventory_code
  find("#process_helper .button").click
  wait_until { all("#process_helper .loading", :visible => true).size == 0 }
end

Then /^the item is added to the hand over for the provided date range and the inventory code is already assigend$/ do
  @customer.contracts.unsigned.last.items.include?(Item.find_by_inventory_code(@inventory_code)).should == true
  assigned_inventory_codes = all(".line .inventory_code input[type=text]").map(&:value)
  assigned_inventory_codes.should include(@inventory_code)
end

When /^I add an option to the hand over by providing an inventory code and a date range$/ do
  @inventory_code = @user.managed_inventory_pools.first.options.first.inventory_code
  find("#code").set @inventory_code
  page.execute_script('$("#code").focus()')
  find("#process_helper .button").click
  wait_until(5){ all("#process_helper .loading", :visible => true).size == 0 }
end

Then /^the (.*?) is added to the hand over$/ do |type|
  case type
  when "option"
    @customer.contracts.unsigned.last.options.include?(Option.find_by_inventory_code(@inventory_code)).should == true
    find(".option_line .inventory_code", :text => @inventory_code)
  when "model"
    @customer.contracts.unsigned.last.models.include?(@model).should == true
    find(".item_line", :text => @model.name)
  end
end

When /^I add an option to the hand over which is already existing in the selected date range by providing an inventory code$/ do
  step 'I add an option to the hand over by providing an inventory code and a date range'
  step 'the option is added to the hand over'
  step 'I add an option to the hand over by providing an inventory code and a date range'
end

Then /^the existing option quantity is increased$/ do
  matching_option_lines = @customer.contracts.unsigned.last.option_lines.select{|x| x.option.inventory_code == @inventory_code}
  matching_option_lines.size.should == 1
  all(".option_line.line", :text => @inventory_code).size.should == 1
  matching_option_lines.first.quantity == 2
  all(".option_line.line", :text => @inventory_code).first.find(".quantity input").value.to_i.should == 2
end

When /^I type the beginning of (.*?) name to the add\/assign input field$/ do |type| 
  @target_name = case type
    when "an option"
      @option = @user.managed_inventory_pools.first.options.first
      @inventory_code = @option.inventory_code
      @option.name
    when "a model"
      @model = @user.managed_inventory_pools.first.items.in_stock.first.model
      @model.name
    when "a template"
      @template = @user.managed_inventory_pools.first.templates.first
      @template.name
  end
  find("#code").set @target_name[0..(@target_name.size/2)]
  wait_until(5){ find("#process_helper .loading", :visible => true) }
  wait_until(10){ all("#process_helper .loading", :visible => true).size == 0 }
end

Then /^I see a list of suggested (.*?) names$/ do |type|
  page.execute_script('$("#code").focus()')
  wait_until(10){ find(".ui-autocomplete") }
end

When /^I select the (.*?) from the list$/ do |type|
  wait_until(10){ find(".ui-autocomplete a", :text => @target_name) }
  find(".ui-autocomplete a", :text => @target_name).click
  wait_until(10){ all("#process_helper .loading", :visible => true).size == 0 }
end

Then /^each model of the template is added to the hand over for the provided date range$/ do
  @template.models.each do |model|
    @model = model
    step 'the (.*?) is added to the hand over'
  end
end

When /^I add so many lines that I break the maximal quantity of an model$/ do
  @model = @customer.contracts.unsigned.last.lines.first.model
  @target_name = @model.name
  (@model.items.size+1).times do 
    find("#code").set @target_name
    step 'I see a list of suggested model names'
    step 'I select the model from the list'
    sleep(1)
  end
end

Then /^I see that all lines of that model have availability problems$/ do
  @lines = all(".item_line", :text => @target_name)
  @lines.each do |line|
    line.should have_content "Problem"
  end
end