# encoding: utf-8


When(/^I navigate to the admin area$/) do
  within 'nav.topbar' do
    find('.navbar-right .dropdown-toggle', match: :first).click
    find('.navbar-right .dropdown-menu a', text: _('Admin')).click
  end
end

When(/^I create a new inventory pool in the admin area's inventory pool tab$/) do
  expect(current_path).to eq admin.inventory_pools_path
  click_link _('Create %s') % _('Inventory pool')
end

When(/^I enter name, shortname and email address$/) do
  find("input[name='inventory_pool[name]']").set 'test'
  find("input[name='inventory_pool[shortname]']").set 'test'
  find("input[name='inventory_pool[email]']").set 'test@test.ch'
end

Then(/^the inventory pool is saved$/) do
  expect(InventoryPool.find_by_name_and_shortname_and_email('test', 'test', 'test@test.ch')).not_to be_nil
end

Then(/^I see the list of all inventory pools$/) do
  expect(has_content?(_('List of Inventory Pools'))).to be true
  within '.list-of-lines' do
    InventoryPool.all.each do |ip|
      find '.row', match: :prefer_exact, text: ip.name
    end
  end
end

When(/^I don't enter (.+)$/) do |must_field|
  step 'I enter name, shortname and email address'
  within('.form-group .col-sm-6 strong', match: :first, text: must_field) do
    find(:xpath, './../..').find('input').set ''
  end
end

Then(/^the inventory pool is not created$/) do
  expect(has_no_content?(_('List of Inventory Pools'))).to be true
  expect(has_no_selector?('.success')).to be true
end

# The shitty sentence structure is due to Cucumber's stupid global steps, this would be ambiguous otherwise
When(/^I edit in the admin area's inventory pool tab an existing inventory pool$/) do
  @current_inventory_pool = InventoryPool.order('RAND()').first
  expect(has_content?(_('List of Inventory Pools'))).to be true
  find('.row', match: :prefer_exact, text: @current_inventory_pool.name).click_link _('Edit')
end

When(/^I change name, shortname and email address$/) do
  all('.row .col-sm-6 strong', text: _('Name')).first.find(:xpath, './../..').find('input').set 'test'
  all('.row .col-sm-6 strong', text: _('Short Name')).first.find(:xpath, './../..').find('input').set 'test'
  all('.row .col-sm-6 strong', text: _('E-Mail')).first.find(:xpath, './../..').find('input').set 'test@test.ch'
end


When(/^I delete an existing inventory pool in the admin area's inventory pool tab$/) do
  @current_inventory_pool = InventoryPool.find(&:can_destroy?) || FactoryGirl.create(:inventory_pool)
  visit admin.inventory_pools_path
  within('.row', text: @current_inventory_pool.name) do
    find(:xpath, '.').click # NOTE it scrolls to the target line
    within '.line-actions' do
      find('.dropdown-toggle').click
      find('.dropdown-menu a', text: _('Delete')).click
    end
  end
end

Then(/^the inventory pool is removed from the list$/) do
  find('#flash .success', text: _('%s successfully deleted') % _('Inventory Pool'))
  expect(has_no_content?(@current_inventory_pool.name)).to be true
end

Then(/^the inventory pool is deleted from the database$/) do
  expect(InventoryPool.find_by_name(@current_inventory_pool.name)).to eq nil
end

Then(/^the list of inventory pools is sorted alphabetically$/) do
  names = all('div.dropdown-holder:nth-child(1) .dropdown .dropdown-item').map(&:text)
  expect(names.map(&:downcase).sort).to eq names.map(&:downcase)
end

Then(/^I see all managed inventory pools$/) do
  if @current_user.inventory_pools.managed.exists?
    within '#ip-dropdown-menu' do
      @current_user.inventory_pools.managed.each {|ip| has_content? ip.name}
    end
  end
end
