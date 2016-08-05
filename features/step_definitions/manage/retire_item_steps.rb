# encoding: utf-8

def get_scope(item_type)
  case item_type
  when 'item' then :items
  when 'license' then :licenses
  end
end


Given(/^I pick a (license|item) that is in stock$/) do |item_type|
  @item = Item.send(get_scope item_type).where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock?}
  step "I go to this %s's edit page" % item_type
end


Given(/^I pick a (license|item) that is in stock and that the current inventory pool is the owner of$/) do |item_type|
  @item = Item.send(get_scope item_type).where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock? and i.owner_id == @current_inventory_pool.id}
  step format("I go to this %s's edit page", item_type)
end


Then(/^I can retire this (?:.*) if I give a reason for retiring$/) do
  field = find("[data-type='field']", text: _('Retirement'))
  field.find("option[value='true']").select_option
  field = find("[data-type='field']", text: _('Reason for Retirement'))
  field.find('textarea').set 'test'
  find('#item-save').click
  step 'I receive a notification of success'
  @item.reload
  expect(@item.retired).to eq Date.today
  expect(@item.retired_reason).to eq 'test'
end


Then(/^I cannot retire such a (?:item|license)$/) do
  field = find("[data-type='field']", text: _('Retirement'))
  if field[:"data-editable"] == 'true'
    field.find("option[value='true']").select_option
    field = find("[data-type='field']", text: _('Reason for Retirement'))
    field.find('textarea').set 'test'
    find('#item-save').click
    step 'I see an error message'
  end
  @item.reload
  expect(@item.retired).to eq nil
end


Then(/^the newly retired (?:item|license) immediately disappears from the inventory list$/) do
  expect(has_no_content?(@item.inventory_code)).to be true
end


Given(/^I pick a (item|license) that is not in stock$/) do |item_type|
  @item = Item.send(get_scope item_type)
          .where(inventory_pool_id: @current_inventory_pool.id)
          .detect { |i| !(i.retired? || i.in_stock?) }
  step format("I go to this %s's edit page", item_type)
end


Given(/^I pick a (.*) the current inventory pool is not the owner of$/) do |item_type|
  @item = Item.send(get_scope item_type)
          .where(inventory_pool_id: @current_inventory_pool.id)
          .detect { |i| i.in_stock? && i.owner_id != @current_inventory_pool.id }
  step format("I go to this %s's edit page", item_type)
end


Given(/^I don't give any reason for retiring this item$/) do
  field = find("[data-type='field']", text: _('Retirement'))
  field.find("option[value='true']").select_option
  field = find("[data-type='field']", text: _('Reason for Retirement'))
  field.find('textarea').set ''
  find('#item-save').click
  step 'I see an error message'
end


Then(/^the (?:.*) is not retired$/) do
  expect(@item.reload.retired).to eq nil
end



Given(/^I pick a retired (.*) that the current inventory pool is the owner of$/) do |item_type|
  @item = Item.unscoped.send(get_scope item_type)
          .find { |i| i.retired? && i.owner_id == @current_inventory_pool.id }
end


When(/^I unretire this (?:.*)$/) do
  expect(has_content?(_('Retirement'))).to be true
  find("[name='item[retired]']").select _('No')
end


Then(/^I am redirected to the inventory list$/) do
  expect(has_content?(_('List of Inventory'))).to be true
  expect(current_path).to eq manage_inventory_path(@current_inventory_pool)
end


Then(/^this (?:.*) is not retired$/) do
  expect(@item.reload.retired?).to be false
end


And(/^I fill in the supply category$/) do
  find('.row.emboss', match: :prefer_exact, text: 'Supply Category')
    .find("select option:not([value=''])", match: :first)
    .select_option if @item.type == 'Item'
end

Given(/^I pick a retired (.*) that the current inventory pool is responsible for but not the owner of$/) do |item_type|
  @item = Item.unscoped.send(get_scope item_type).find {|i| i.retired? and i.owner != @current_inventory_pool and i.inventory_pool == @current_inventory_pool}
end
