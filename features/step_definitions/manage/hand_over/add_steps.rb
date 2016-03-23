When /^I add (a|an|a borrowable|an unborrowable) (item|license) to the hand over by providing an inventory code$/ do |item_attr, item_type|
  existing_model_ids = @customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool).models.map(&:id)
  items = @current_inventory_pool.items.send(item_type.pluralize)
  @inventory_codes ||= []
  @inventory_code = case item_attr
                      when 'a', 'an'
                        items.in_stock
                      when 'a borrowable'
                        items.in_stock.where(is_borrowable: true)
                      when 'an unborrowable'
                        items.in_stock.where(is_borrowable: false)
                    end.detect{|i| not existing_model_ids.include?(i.model_id)}.inventory_code
  @inventory_codes << @inventory_code
  find('[data-add-contract-line]').set @inventory_code
  find('.line', match: :first)
  line_amount_before = all('.line').size
  find('[data-add-contract-line] + .addon').click
  find('#flash')
  find('.line', match: :first)
  find("input[value='#{@inventory_code}']")
  expect(line_amount_before).to be < all('.line').size
end

When /^I add (a|an|a borrowable|an unborrowable) (item|license) to the hand over by using the search input field$/ do |item_attr, item_type|
  items = @current_inventory_pool.items.unretired.send(item_type.pluralize)
  @inventory_codes ||= []
  @item = case item_attr
           when 'a', 'an'
             items.in_stock
           when 'a borrowable'
             items.in_stock.where(is_borrowable: true)
           when 'an unborrowable'
             items.in_stock.where(is_borrowable: false)
           end.order('RAND()').first
  @model = @item.model
  @inventory_codes << @item.inventory_code
  fill_in 'assign-or-add-input', with: @item.model.name
  find('.ui-menu-item', text: @item.model.name).click
  find('.line', text: @item.model.name, match: :first).find('form[data-assign-item-form] input').click
  find('.ui-menu-item', text: @item.inventory_code).click
end

Then /^the item is added to the hand over for the provided date range and the inventory code is already assigend$/ do
  expect(@customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool).items.include?(Item.find_by_inventory_code(@inventory_code))).to be true
  assigned_inventory_codes = all('.line input[data-assign-item]').map(&:value)
  expect(assigned_inventory_codes).to include @inventory_code
end

When /^I add an option to the hand over by providing an inventory code and a date range$/ do
  @inventory_code = if @option
                      @option
                    else
                      existing_options = if @contract
                                           @contract.options
                                         elsif @customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool)
                                           @customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool).options
                                         else
                                           []
                                         end
                      (@current_inventory_pool.options.order('RAND()') - existing_options).first
                    end.inventory_code
  find('[data-add-contract-line]').set @inventory_code
  find('[data-add-contract-line] + .addon').click
  find(".line[data-line-type='option_line'] .grey-text", text: @inventory_code)
  step 'the option is added to the hand over'
end

Then /^the (.*?) is added to the hand over$/ do |type|
  contract = @customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool)
  case type
    when 'option'
      find(".line[data-line-type='option_line'] .col1of10", match: :prefer_exact, text: @inventory_code)
      option = Option.find_by_inventory_code(@inventory_code)
      find('#flash', text: option.name)
      @option_line = contract.reload.option_lines.where(option_id: option).order(:created_at).last
      expect(contract.reload.options).to include option
    when 'model'
      find(".line[data-line-type='item_line'] .col4of10", match: :prefer_exact, text: @model.name)
      expect(contract.reload.models.include?(@model)).to be true
  end
end

When /^I add an option to the hand over which is already existing in the selected date range by providing an inventory code$/ do
  option_line = @contract.option_lines.order('RAND()').first
  @option = option_line.option
  @quantity_before = option_line.quantity
  @n = rand(2..5)
  @n.times do
    step 'I add an option to the hand over by providing an inventory code and a date range'
  end
end

Then /^the existing option quantity is increased$/ do
  find(".line[data-line-type='option_line']", text: @option.inventory_code)
  @option_line.reload
  within(".line[data-line-type='option_line']", text: @option.inventory_code) do
    find("input[value='#{@option_line.quantity}']")
  end
  expect(@option_line.quantity).to eq (@quantity_before + @n)
end

When /^I type the beginning of (.*?) name to the add\/assign input field$/ do |type|
  @target_name = case type
    when 'an option'
      @option = @current_inventory_pool.options.first
      @inventory_code = @option.inventory_code
      @option.name
    when 'a model'
      @model = @current_inventory_pool.items.in_stock.first.model
      @model.name
    when 'that model'
      @model.name
    when 'a template'
      @template = @current_inventory_pool.templates.first
      @template.name
  end
  type_into_autocomplete '[data-add-contract-line]', @target_name[0..-2]
end

Then /^I see a list of suggested (.*?) names$/ do |type|
  find('[data-add-contract-line]').click
  within '.ui-autocomplete' do
    find('a', match: :first)
  end
end

Then(/^I see that model in the list of suggested model names as "(.*?)"$/) do |arg1|
  case arg1
    when 'not borrowable'
      find('.ui-autocomplete a.light-red', match: :prefer_exact, text: @target_name)
    else
      'not found'
  end
end


When /^I select the (.*?) from the list$/ do |type|
  # trick closing possible tooltips
  page.driver.browser.action.move_to(find('nav#topbar').native).perform

  within '.ui-autocomplete' do
    find('a', match: :prefer_exact, text: @target_name).click
  end
end

Then /^each model of the template is added to the hand over for the provided date range$/ do
  sleep 1
  @template.models.each do |model|
    @model = model
    step 'the (.*?) is added to the hand over'
  end
end

When /^I add so many reservations that I break the maximal quantity of a model$/ do
  @model ||= (@contract || @customer.reservations_bundles.approved.find_by(inventory_pool_id: @current_inventory_pool)).item_lines.order('RAND()').first.model
  @target_name = @model.name
  quantity_to_add = if @contract
                      start_date = Date.parse find('#add-start-date').value
                      end_date = Date.parse find('#add-end-date').value
                      @model.availability_in(@current_inventory_pool).maximum_available_in_period_summed_for_groups start_date, end_date, @contract.user.groups.map(&:id)
                    else
                      @model.items.size
                    end
  @quantity_added = [quantity_to_add+1, 0].max
  @quantity_added.times do
    type_into_autocomplete '[data-add-contract-line]', @target_name
    step 'I see a list of suggested model names'
    step 'I select the model from the list'
  end
end

Then /^I see that all reservations of that model have availability problems$/ do
  find(".line[data-line-type='item_line']", match: :prefer_exact, text: @target_name)
  @lines = all(".line[data-line-type='item_line']", text: @target_name)
  @lines.each do |line|
    line.find('.line-info.red')
  end
end

When /^I add an item to the hand over$/ do
  find('[data-add-contract-line]').set @item.inventory_code
  find('[data-add-contract-line] + .addon').click
  find('#flash')
end

Given(/^there is a model or software which all items are set to "(.*?)"$/) do |arg1|
  @model = case arg1
             when 'not borrowable'
               @current_inventory_pool.models.order('RAND ()').detect { |m| m.items.all? { |i| not i.is_borrowable? } }
             else
               'not found'
           end
end
