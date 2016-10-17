# -*- encoding : utf-8 -*-

Given(/^I edit an item that belongs to the current inventory pool( and is in stock)?( and is not part of any contract)?$/) do |in_stock, not_in_contract|
  items = @current_inventory_pool.items.items.where(owner_id: @current_inventory_pool, models: {is_package: false}).order('RAND()')
  items = items.in_stock if in_stock

  @item = if not_in_contract
            items.detect { |i| Reservation.where(item_id: i.id).empty? }
          else
            items.first
          end

  visit manage_edit_item_path @current_inventory_pool, @item
  expect(has_selector?('.row.emboss')).to be true
end

Then(/^"(.*?)" must be selected in the "(.*?)" section$/) do |key, section|
  field = find("[data-type='field']", text: key)
  expect(field[:"data-required"]).to eq 'true'
end

When(/^"(.*?)" is selected for "(.*?)", "(.*?)" must also be supplied$/) do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.find('label,option', match: :first, text: value).click
  newfield = find("[data-type='field']", text: newkey)
  expect(newfield[:"data-required"]).to eq 'true'
end

Then(/^all required fields are marked with an asterisk$/) do
  all(".field[data-required='true']", visible: true).each do |field|
    expect(field.text[/\*/]).not_to be_nil
  end
  all(".field:not([data-required='true'])").each do |field|
    expect(field.text[/\*/]).to eq nil
  end
end

Then(/^I cannot save the item if a required field is empty$/) do
  find(".field[data-required='true'] textarea", match: :first).set('')
  find(".field[data-required='true'] input[type='text']", match: :first).set('')
  find('#save').click
  step 'I see an error message'
  expect(@item.to_json).to eq @item.reload.to_json
end


When(/^the required fields are highlighted in red$/) do
  all(".field[data-required='true']", visible: true).each do |field|
    if field.all('input[type=text]').any? { |input| input.value == 0 } or
        field.all('textarea').any? { |textarea| textarea.value == 0 } or
        (ips = field.all('input[type=radio]'); ips.all? { |input| not input.checked? } if not ips.empty?)
      expect(field[:class][/invalid/]).not_to be_nil
    end
  end
end


Then(/^I see form fields in the following order:$/) do |table|
  expected_values = []
  expected_headlines = []
  table.rows.each do |tr|
    expected_headlines << tr[0] if tr[0].match(/^\-.*\-$/)
    expected_values << tr[0].chomp if !tr[0].match(/^\-.*\-$/)
  end
  headlines = find('#flexible-fields').all('h2').map { |hl| "- #{hl.text} -" }.compact
  values = find('#flexible-fields').all("div[data-type='key']").map do |element|
    element.text.gsub(' *','').chomp
  end
  expect(headlines).to eq(expected_headlines)
  expect(values).to eq(expected_values)
end

When(/^"(.*?)" is selected for "(.*?)", "(.*?)" must also be selected$/) do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.find('option', match: :first, text: value).select_option
  newfield = find("[data-type='field']", text: newkey)
  expect(newfield[:"data-required"]).to eq 'true'
end

When(/^I delete the supplier$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Supplier')).find('input').set ''
end

Then(/^the new supplier is deleted$/) do
  expect(has_content?(_('List of Inventory'))).to be true
  expect(Supplier.find_by_name(@new_supplier)).not_to be_nil
end

Then(/^the item has no supplier$/) do
  expect(has_content?(_('List of Inventory'))).to be true
  expect(@item.reload.supplier).to eq nil
end

And(/^I navigate to the edit page of an item that has a supplier$/) do
  @item = @current_inventory_pool.items.find { |i| not i.supplier.nil? }
  step "I go to this item's edit page"
end

When(/^I change the supplier$/) do
  @supplier = Supplier.first
  @new_supplier = @supplier.name # A later step looks for this instead of @supplier, maybe
                            # fix the later step instead?
  fill_in_autocomplete_field _('Supplier'), @supplier.name
end

Given(/^I edit an item that belongs to the current inventory pool and is not in stock$/) do
  @item = @current_inventory_pool.own_items.not_in_stock.order('RAND()').first
  @item_before = @item.to_json
  step "I go to this item's edit page"
end

When(/^I change the responsible department$/) do
  fill_in_autocomplete_field _('Responsible'), InventoryPool.where('id != ?', @item.inventory_pool.id).order('RAND()').first.name
end

When(/^I change the model$/) do
  fill_in_autocomplete_field _('Model'), @current_inventory_pool.models.order('RAND()').detect { |m| m != @item.model }.name
end

When(/^I retire the item$/) do
  find('.row.emboss', match: :prefer_exact, text: _('Retirement')).find('select', match: :first).select _('Yes')
  find('.row.emboss', match: :prefer_exact, text: _('Reason for Retirement')).find('input, textarea', match: :first).set 'Retirement reason'
end

Given(/^there is a model without a version$/) do
  @model = Model.find { |m| !m.version }
  expect(@model).not_to be_nil
end

When(/^I assign this model to the item$/) do
  fill_in_autocomplete_field _('Model'), @model.name
end

Then(/^there is only product name in the input field of the model$/) do
  expect(find("input[data-autocomplete_value_target='item[model_id]']").value).to eq @model.product
end
