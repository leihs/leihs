# encoding: utf-8

When(/^I make a note of the original inventory code$/) do
  @inventory_code_original = find('.row.emboss', match: :prefer_exact, text: _('Inventory Code')).find('input', match: :first).value
end

When(/^I save and copy$/) do
  find('.content-wrapper .dropdown-holder', match: :first).click
  find("a[id='item-save-and-copy']", match: :first).click
end

Then(/^the item is saved$/) do
  # This seems wrong, the page doesn't have that page title, and besides,
  # there is a separate step testing for the page title explicitly.
  #expect(has_content?(_("Create copied item"))).to be true
  find '#flash'
  @new_item = Item.find_by_inventory_code(@inventory_code_original)
  expect(@new_item.blank?).to be false
end

Then(/^I can create a new item$/) do
  expect(current_path).to eq manage_copy_item_path(@current_inventory_pool, @new_item.id)
end

Then(/^the page title is 'Create copied item'$/) do
  expect(has_content?(_('Create copied item'))).to be true
end

Then(/^I can cancel$/) do
  find('.button', match: :first, text: _('Cancel'))
end

Then(/^all fields except the following were copied:$/) do |table|
  not_copied_fields = table.raw.flatten
  @table_hashes.each do |hash_row|
    field_name = hash_row['field']
    field_value = hash_row['value']
    field_type = hash_row['type']

    within('.row.emboss', match: :prefer_exact, text: field_name) do
      case field_type
      when 'autocomplete'
        expect(find('input,textarea', match: :first).value).to eq (field_value != 'None' ? field_value : '')
      when 'select'
        expect(all('option').detect(&:selected?).text).to eq field_value
      when 'radio must'
        expect(find("input[checked][type='radio']", match: :first).value).to eq field_value
      when ''
        if not_copied_fields.include? field_name
          if field_name == _('Inventory Code')
            expect(find('input,textarea', match: :first).value).not_to eq @inventory_code_original
          else
            expect(find('input,textarea', match: :first).value.blank?).to be true
          end
        else
          expect(find('input,textarea', match: :first).value).to eq field_value
        end
      end
    end
  end
end

Then(/^the inventory code is already filled in$/) do
  @inventory_code_copied = find('.row.emboss', match: :prefer_exact, text: _('Inventory Code')).find('input', match: :first).value
  expect(@inventory_code_copied.blank?).to be false
end

Then(/^the copied item is saved$/) do
  expect(has_content?(_('List of Inventory'))).to be true
  @copied_item = Item.find_by_inventory_code(@inventory_code_copied)
  expect(@copied_item).not_to be_nil
end

Then(/^an item copy screen is shown$/) do
  sleep 1
  expect(current_path).to eq manage_copy_item_path(@current_inventory_pool, @item)
end

Then(/^all fields except inventory code, serial number and name are copied$/) do
  expect(find('.row.emboss', match: :prefer_exact, text: _('Inventory Code')).find('input,textarea', match: :first).value == @item.inventory_code).to be false
  expect(find('.row.emboss', match: :prefer_exact, text: _('Inventory Code')).find('input,textarea', match: :first).value.empty?).to be false
  expect(find('.row.emboss', match: :prefer_exact, text: _('Model')).find('input,textarea', match: :first).value).to eql @item.model.name
  expect(find('.row.emboss', match: :prefer_exact, text: _('Serial Number')).find('input,textarea', match: :first).value.empty?).to be true
  expect(find('.row.emboss', match: :prefer_exact, text: _('Name')).find('input,textarea', match: :first).value.empty?).to be true
end

When(/^I copy an item$/) do
  @item = Item.where(inventory_pool_id: @current_inventory_pool).detect {|i| not i.retired? and not i.serial_number.nil? and not i.name.nil?}
  step %Q(I search for "%s") % @item.model.name
  step 'expand the corresponding model'
  within(".line[data-type='item'][data-id='#{@item.id}']", text: @item.inventory_code) do
    find('.dropdown-holder').click
    find('a', text: _('Copy Item')).click
  end
end


When(/^I am editing a(?:n) (item|software license)$/) do |arg1|
  s0, s1, s2, s3 = case arg1
                     when 'item'
                       ['items', 'model', 'item', _('Edit Item')]
                     when 'software license'
                       ['licenses', 'software', 'license', _('Edit License')]
                   end

  @item = @current_inventory_pool.items.send(s0).where(retired: nil).order('RAND()').first
  step %Q(I search for "%s") % @item.model.name
  within(".line[data-type='#{s1}']", match: :prefer_exact, text: @item.model.name) do
    find("[data-type='inventory-expander']").click
  end
  within(".group-of-lines .line[data-type='#{s2}'][data-id='#{@item.id}']", text: @item.inventory_code) do
    find('.button', text: s3).click
  end
end

When(/^I edit an item belonging to a different inventory pool$/) do
  @item = Item.find {|i| i.inventory_pool_id == @current_inventory_pool.id and @current_inventory_pool.id != i.owner_id}
  step "I go to this item's edit page"
  expect(has_selector?('.field')).to be true
  @fields = all('.field:not(.editable)')
  expect(@fields.size).to be > 0
end

Then(/^all fields are editable, because the current inventory pool owns this new item$/) do
  expect(has_selector?('.field')).to be true
  @fields = all(".field[data-editable='false']")
  expect(@fields.size).to eq 0
end

When(/^I make a note of the inventory code for further steps$/) do
  @inventory_code = find('.row.emboss', match: :prefer_exact, text: _('Inventory Code')).find('input,textarea').value
end
