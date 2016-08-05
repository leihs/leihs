# encoding: utf-8

Then(/^I see a tab where I can change to the inventory helper$/) do
  find('#inventory-index-view nav a.navigation-tab-item', text: _('Helper')).click
  find('h1', text: _('Inventory Helper'))
end

Then /^I choose all fields through a list or by name$/ do
  i = find('#inventory-helper-view #field-input')
  while(i.click and page.has_selector?('.ui-menu-item a', visible: true)) do
    find('.ui-menu-item a', match: :first, visible: true).click
  end
end

Then /^I set all their initial values$/ do
  @parent_el ||= find('#field-selection')
  @data = {}
  Field.all.each do |field|
    next if @parent_el.all(".field[data-id='#{field.id}']").empty?
    field_el = @parent_el.find(".field[data-id='#{field.id}']")
    case field.data['type']
      when 'radio'
        r = field_el.find('input[type=radio]', match: :first)
        r.click
        @data[field.id] = r.value
      when 'textarea'
        ta = field_el.find('textarea')
        ta.set 'This is a text for a textarea'
        @data[field.id] = ta.value
      when 'select'
        o = field_el.find('option', match: :first)
        o.select_option
        @data[field.id] = o.value
      when 'text'
        within field_el do
          string = if all("input[name='item[inventory_code]']").empty?
                     'This is a text for a input text'
                   else
                     '123456'
                   end
          i = find("input[type='text']")
          i.set string
          @data[field.id] = i.value
        end
      when 'date'
        dp = field_el.find("[data-type='datepicker']")
        ori_value = dp.value
        dp.set ''
        dp.set ori_value
        within '.ui-datepicker-calendar' do
          find('.ui-state-highlight, .ui-state-active', visible: true, match: :first).click
        end
        @data[field.id] = dp.value
      when 'autocomplete'
        target_name = find(".field[data-id='#{field.id}'] [data-type='autocomplete']")['data-autocomplete_value_target']
        find(".field[data-id='#{field.id}'] [data-type='autocomplete'][data-autocomplete_value_target='#{target_name}']").click
              find('.ui-menu-item a', match: :first).click
        @data[field.id] = find(".field[data-id='#{field.id}'] [data-type='autocomplete']")
      when 'autocomplete-search'
        model = if @item and @item.children.exists? # item is a package
                  Model.all.find &:is_package?
                else
                  Model.all.find {|m| not m.is_package?}
                end
        string = model.name
        within ".field[data-id='#{field.id}']" do
          find('input').click
          find('input').set string
        end
        find('.ui-menu-item a', match: :prefer_exact, text: string).click
        @data[field.id] = Model.find_by_name(string).id
      when 'checkbox'
        # currently we only have "ausgemustert"
        field_el.find("input[type='checkbox']").click
        find("[name='item[retired_reason]']").set 'This is a text for a input text'
        @data[field.id] = 'This is a text for a input text'
      else
        raise 'field type not found'
    end
  end
end

Then /^I set the field "(.*?)" to "(.*?)"$/ do |field_name, value|
  field = Field.find(find(".row.emboss[data-type='field']", match: :prefer_exact, text: field_name)['data-id'].to_sym)
  within(".field[data-id='#{field.id}']") do
    case field.data['type']
      when 'radio'
        find('label', text: value).click
      when 'select'
        find('option', text: value).select_option
      when 'checkbox'
        find('label', text: value).click
      else
        raise 'unknown field'
    end
  end
end

Then /^I scan or enter the inventory code of an item that is in stock and not in any contract$/ do
  @item = @current_inventory_pool.items.in_stock.order('RAND()').first
  within('#item-selection') do
    find('[data-barcode-scanner-target]').set @item.inventory_code
    find('button[type=submit]').click
  end
end


Then /^I scan or enter the inventory code( of an item belonging to the current inventory pool)?$/ do |arg1|
  @item ||= if arg1
              @current_inventory_pool.items.where(owner_id: @current_inventory_pool)
            else
              @current_inventory_pool.items
            end.in_stock.order('RAND()').first
  within('#item-selection') do
    find('[data-barcode-scanner-target]').set @item.inventory_code
    find('button[type=submit]').click
  end
end

Then /^I see all the values of the item in an overview with model name and the modified values are already saved$/ do
  FastGettext.locale = @current_user.language.locale_name.gsub(/-/, '_')
  Field.all.each do |field|
    next if all(".field[data-id='#{field.id}']").empty?
    within('form#flexible-fields') do
      field_el = find(".field[data-id='#{field.id}']")
      value = field.get_value_from_params @item.reload
      field_type = field.data['type']
      if field_type == 'date'
        unless value.blank?
          value = Date.parse(value) if value.is_a?(String)
          field_el.has_content? value.year
          field_el.has_content? value.month
          field_el.has_content? value.day
        end
      elsif field.data['attribute'] == 'retired'
        unless value.blank?
          field_el.has_content? _(field.values.first['label'])
        end
      elsif field_type == 'radio'
        if value
          value = field.values.detect{|v| v['value'] == value}['label']
          field_el.has_content? _(value)
        end
      elsif field_type == 'select'
        if value
          value = field.values.detect{|v| v['value'] == value}['label']
          field_el.has_content? _(value)
        end
      elsif field_type == 'autocomplete'
        if value
          value = field.as_json['values'].detect{|v| v['value'] == value}['label']
          field_el.has_content? _(value)
        end
      elsif field_type == 'autocomplete-search'
        if value
          if field.data['label'] == 'Model'
            value = Model.find(value).name
            field_el.has_content? value
          end
        end
      else
        field_el.has_content? _(value)
      end
    end
  end

  find("form#flexible-fields .field[data-id='#{Field.all.detect{|f| f.data['label'] == "Model" }.id}']", text: @item.reload.model.name)
end

Then /^the changed values are highlighted$/ do
  all('#field-selection .field', minimum: 1).each do |selected_field|
    c = all("#item-section .field[data-id='#{selected_field['data-id']}'].success").count + all("#item-section .field[data-id='#{selected_field['data-id']}'].error").count
    expect(c).to eq 1
  end
end

Then /^I choose the fields from a list or by name$/ do
  field = Field.all.select{|f| f.data['readonly'] == nil and f.data['type'] != 'autocomplete-search' and f.data['target_type'] != 'license' and not f.data['visibility_dependency_field_id']}.last
  find('#field-input').click
  find('#field-input').set _(field.data['label'])
  find('.ui-menu-item a', match: :first, text: _(field.data['label'])).click
  within '#field-selection' do
    @all_editable_fields = all('.field', visible: true)
  end
end

Then /^I set their initial values$/ do
  within '#field-selection' do
    fields = all('.field input, #field-selection .field textarea', visible: true)
    expect(fields.count).to be > 0
    fields.each do |input|
      input.set 'Test123'
    end
  end
end

Then /^I scan or enter the inventory code of an item that can't be found$/ do
  @not_existing_inventory_code = 'THIS FOR SURE NO INVENTORY CODE'
  within('#item-selection') do
    find('[data-barcode-scanner-target]').set @not_existing_inventory_code
    find('button[type=submit]').click
  end
end

Then /^I start entering an item's inventory code$/ do
  @item= @current_inventory_pool.items.first
  find('#item-selection [data-barcode-scanner-target]').set @item.inventory_code[0..1]
end


Then /^I choose the item from the list of results$/ do
  expect(has_selector?('.ui-menu-item')).to be true
  # This sometimes finds multiple results. How is that even possible?
  find('.ui-menu-item a', text: @item.inventory_code).click
end

Given /^I edit an item through the inventory helper using an inventory code$/ do
  step 'I go to the inventory helper screen'
  step 'I choose the fields from a list or by name'
  step 'I set their initial values'
  step 'I scan or enter the inventory code of an item belonging to the current inventory pool'
  step 'I see all the values of the item in an overview with model name and the modified values are already saved'
  step 'the changed values are highlighted'
end

When /^I use the edit feature$/ do
  find('#item-section button#item-edit', text: _('Edit Item')).click
end

Then /^I can edit all of this item's values right then and there$/ do
  @parent_el = find('#item-section')
  step 'I set their initial values'
end

Then /^my changes are saved$/ do
  step %Q{I see all the values of the item in an overview with model name and the modified values are already saved}
end

When /^I cancel$/ do
  find('#item-section a', text: _('Cancel')).click
end

Then /^the changes are reverted$/ do
  expect(@item.to_json).to eq @item.reload.to_json
end

Then(/^I select the field "(.*?)"$/) do |field|
  find('#field-input').click
  find('#field-input').set field
  find('.ui-menu-item a', match: :prefer_exact, text: field).click
  within '#field-selection' do
    @all_editable_fields = all('.field', visible: true)
  end
end

Then(/^I set some value for the field "(.*?)"$/) do |field|
  find('.row.emboss', match: :prefer_exact, text: field).find('input').set 'Test123'
end

Given(/^there is an item that shares its location with another$/) do
  location = Location.find {|l| l.items.where(inventory_pool_id: @current_inventory_pool, parent_id: nil).count >= 2}
  @item, @item_2 = location.items.where(inventory_pool_id: @current_inventory_pool, parent_id: nil).order('RAND()').limit(2)
  @item_2_location = @item_2.location
end

Then(/^I enter the start of the inventory code of the specific item$/) do
  find('#item-selection [data-barcode-scanner-target]').set @item.inventory_code[0..1]
end

Then(/^the location of the other item has remained the same$/) do
  expect(@item_2.reload.location).to eq @item_2_location
end

When(/^"(.*?)" is selected and set to "(.*?)", then "(.*?)" must also be filled in$/) do |field, value, dependent_field|
  find('#field-input').click
  find('#field-input').set field
  find('.ui-menu-item a', match: :prefer_exact, text: field).click
  step 'I set the field "%s" to "%s"' % [field, value]
  find('.row.emboss', match: :prefer_exact, text: dependent_field)
end

When(/^a required field is blank, the inventory helper cannot be used$/) do
  step %Q{I scan or enter the inventory code}
end

Given(/^I edit the field "(.*?)" of an item that is not in stock$/) do |name|
  step %Q{I select the field "#{name}"}
  @item = @current_inventory_pool.items.not_in_stock.order('RAND()').first
  @item_before = @item.to_json
  step %Q{I scan or enter the inventory code}
end

Then(/^I see an error message that I can't change the responsible inventory pool for items that are not in stock$/) do
  expect(page.has_content?(
      _("The responsible inventory pool cannot be changed because it's not returned yet or has already been assigned to a contract line."))
  ).to be true
  expect(@item_before).to eq @item.reload.to_json
end

Then(/^I see an error message that I can't retire the item because it's already handed over or assigned to a contract$/) do
  expect(has_content?(_("The item cannot be retired because it's not returned yet or has already been assigned to a contract line."))).to be true
  expect(@item_before).to eq @item.reload.to_json
end

Then(/^I see an error message that I can't change the model because the item is already handed over or assigned to a contract$/) do
  expect(has_content?(_('The model cannot be changed because the item is used in contracts already.'))).to be true
  expect(@item_before).to eq @item.reload.to_json
end

Given(/^I edit the field "(.*?)" of an item that is part of a contract$/) do |name|
  step %Q{I select the field "#{name}"}
  @item = @current_inventory_pool.items.not_in_stock.order('RAND()').first
  @item_before = @item.to_json
  fill_in_autocomplete_field name, @current_inventory_pool.models.order('RAND()').detect {|m| m != @item.model}.name
  step %Q{I scan or enter the inventory code}
end

Given(/^I retire an item that is not in stock$/) do
  step %Q{I select the field "Retiremen"}
  find('.row.emboss', match: :prefer_exact, text: _('Retirement')).find('select').select _('Yes')
  find('.row.emboss', match: :prefer_exact, text: _('Reason for Retirement')).find('input, textarea').set 'Retirement reason'
  @item = @current_inventory_pool.items.where(owner: @current_inventory_pool).not_in_stock.order('RAND()').first
  @item_before = @item.to_json
  step %Q{I scan or enter the inventory code}
end

Given(/^I edit the field "Responsible department" of an item that isn't in stock and belongs to the current inventory pool$/) do
  step %Q{I select the field "Responsible department"}
  @item = @current_inventory_pool.items.where(owner: @current_inventory_pool).not_in_stock.order('RAND()').first
  @item_before = @item.to_json
  fill_in_autocomplete_field 'Responsible department', InventoryPool.where.not(id: @current_inventory_pool).order('RAND()').first.name
  step %Q{I scan or enter the inventory code}
end
