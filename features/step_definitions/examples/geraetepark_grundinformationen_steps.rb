# encoding: utf-8


#Wenn(/^ich den Admin\-Bereich betrete$/) do
When(/^I navigate to the inventory pool manage section$/) do
  within '.topbar' do
    find('.topbar-navigation .topbar-item a.topbar-item-inner', text: _('Manage')).click
  end
end

Then(/^I enter the inventory pool's basic settings as follows:$/) do |table|
  @table_raw = table.raw
  @table_raw.flatten.each do |field_name|
    within('.row.padding-inset-s', match: :prefer_exact, text: field_name) do
      if field_name == 'Print Contracts'
        find('input', match: :first).set false
      elsif field_name == 'Automatic access'
        find('input', match: :first).set true
      else
        find('input,textarea', match: :first).set (field_name == 'E-Mail' ? 'test@test.ch' : 'test')
      end
    end
  end
end

When(/^I make a note of which page I'm on$/) do
  @saved_path = current_path
end

Then(/^the settings are updated$/) do
  @table_raw.flatten.each do |field_name|
    within('.row.padding-inset-s', match: :prefer_exact, text: field_name) do
      if field_name == 'Print Contracts'
        expect(find('input', match: :first).selected?).to be false
      elsif field_name == 'Automatic access'
        expect(find('input', match: :first).selected?).to be true
      else
        expect(find('input,textarea', match: :first).value).to eq (field_name == 'E-Mail' ? 'test@test.ch' : 'test')
      end
    end
  end
end

Then(/^I am still on the same page$/) do
  expect(current_path).to eq @saved_path
end

Then(/^I see a confirmation that the information was saved$/) do
  find('#flash .notice', text: _('Inventory pool successfully updated'))
end

When(/^I edit the current inventory pool$/) do
  visit manage_edit_inventory_pool_path(@current_inventory_pool)
end

When(/^I leave the following fields empty:$/) do |table|
  table.raw.flatten.each do |must_field_name|
    find('.row.emboss', match: :prefer_exact, text: must_field_name).find('input,textarea', match: :first).set ''
  end
end

Given(/^I edit my inventory pool settings$/) do
  visit manage_edit_inventory_pool_path(@current_inventory_pool)
end

When(/^I randomly set the workdays monday, tuesday, wednesday, thursday, friday, saturday and sunday to open or closed$/) do
  @workdays = {}
  [0,1,2,3,4,5,6].each do |day|
    select = find('.row.emboss', match: :prefer_exact, text: I18n.t('date.day_names')[day]).find('select', match: :first)
    @workdays[day] = rand > 0.5 ? _('Open') : _('Closed')
    select.find("option[label='#{@workdays[day]}']", match: :first).click
  end
end

Then(/^those randomly chosen workdays are saved$/) do
  @workdays.each_pair do |day, status|
    if status == 'closed'
      expect(@current_inventory_pool.workday.closed_days.include?(day)).to be true
    elsif status == 'open'
      expect(@current_inventory_pool.workday.closed_days.include?(day)).to be false
    end
  end
end

When(/^I set one or more time spans as holidays and give them names$/) do
  @holidays = []
  [1,5,8].each do |i|
    holiday = {start_date: (Date.today + i), end_date: (Date.today + i*i), name: "Test #{i}"}
    @holidays.push holiday
    fill_in 'start_date', with: I18n.l(holiday[:start_date])
    fill_in 'end_date', with: I18n.l(holiday[:end_date])
    fill_in 'name', with: holiday[:name]
    find('.button[data-add-holiday]').click
  end
end

Then(/^the holidays are saved$/) do
  @holidays.each do |holiday|
    expect(@current_inventory_pool.holidays.where(start_date: holiday[:start_date], end_date: holiday[:end_date], name: holiday[:name]).empty?).to be false
  end
end

Then(/^I can delete the holidays$/) do
  holiday = @holidays.last
  find('.row[data-holidays-list] .line', text: holiday[:name]).find('.button[data-remove-holiday]').click
  step 'I save'
  expect(@current_inventory_pool.holidays.where(start_date: holiday[:start_date], end_date: holiday[:end_date], name: holiday[:name]).empty?).to be true
end

# there is nothing in the test that relates to required fields
When(/^I fill in the following fields in the inventory pool settings:$/) do |table|
  table.raw.flatten.each do |field_name|
    expect(find('.row.emboss', match: :prefer_exact, text: field_name).find('input', match: :first).value.length).to be > 0
  end
end

When(/^I leave the field "(.*?)" in the inventory pool settings empty$/) do |field_name|
  find('.row.emboss', match: :prefer_exact, text: field_name).find('input', match: :first).set ''
end

Then(/^I have to supply a reason for suspension$/) do
  fill_in 'inventory_pool[automatic_suspension_reason]', with: ''
  step 'I save'
  step 'I see an error message'
  @reason = Faker::Lorem.sentence
  fill_in 'inventory_pool[automatic_suspension_reason]', with: @reason
  step 'I save'
end

Then(/^this configuration is saved$/) do
  expect(has_selector?('#flash .notice')).to be true
  @current_inventory_pool.reload
  step %Q("Automatic suspension" is enabled)
  expect(@current_inventory_pool.automatic_suspension_reason).to eq @reason
end

When(/^a user is suspended automatically due to late contracts$/) do
  @user = Reservation.where(inventory_pool_id: @current_inventory_pool).signed.where('end_date < ?', Date.today).order('RAND()').first.user
  @user.automatic_suspend(@current_inventory_pool)
end

Then(/^they are suspended for this inventory pool until '(\d+)\/(\d+)\/(\d+)'$/) do |day, month, year|
  @access_right = @user.access_right_for(@current_inventory_pool)
  expect(@access_right.suspended_until).to eq Date.new(year.to_i, month.to_i, day.to_i)
end

Then(/^the reason for suspension is the one specified for this inventory pool$/) do
  expect(@access_right.suspended_reason).to eq @reason
end

When(/^I disable automatic access$/) do
  within('.row.padding-inset-s', match: :prefer_exact, text: _('Automatic access')) do
    find('input', match: :first).set false
  end
end

Then(/^automatic access is disabled$/) do
  expect(@current_inventory_pool.reload.automatic_access).to be false
end

Given(/^I edit an inventory pool( that is granting automatic access)?$/) do |arg1|
  if arg1
    @current_inventory_pool = @current_user.inventory_pools.managed.where(automatic_access: true).order('RAND()').first
    @current_inventory_pool ||= begin
      ip = @current_user.inventory_pools.managed.order('RAND()').first
      ip.update_attributes(automatic_access: true)
      ip
    end
  end
  visit manage_edit_inventory_pool_path(@current_inventory_pool)
  @last_edited_inventory_pool = @current_inventory_pool
end

Given(/^multiple inventory pools are granting automatic access$/) do
  InventoryPool.order('RAND()').limit(rand(2..4)).each do |inventory_pool|
    inventory_pool.update_attributes automatic_access: true
  end
  if inventory_pool = @current_user.inventory_pools.managed.where.not(automatic_access: true).order('RAND()').first
    inventory_pool.update_attributes automatic_access: true
  end
  @inventory_pools_with_automatic_access = InventoryPool.where(automatic_access: true)
  expect(@inventory_pools_with_automatic_access.count).to be > 1
end

Given(/^my inventory pool is granting automatic access$/) do
  @current_inventory_pool.update_attributes automatic_access: true
  @inventory_pools_with_automatic_access = InventoryPool.where(automatic_access: true)
  expect(@inventory_pools_with_automatic_access.count).to be > 1
end

When(/^I create a new user with the 'inventory manager' role in my inventory pool$/) do
  steps %Q{
    When I am looking at the user list
    And I add a user
    And I enter the following information
      | Last name       |
      | First name        |
      | E-Mail         |
    And I enter the login data
    And I enter a badge ID
    And I choose the following roles
      | tab                | role              |
      | Inventory manager | inventory_manager   |
    And I save
  }
  @user = User.find_by_lastname 'test'
end

Then(/^the newly created user has 'customer'-level access to all inventory pools that grant automatic access(, but not to mine)?$/) do |arg1|
  expect(@user.access_rights.count).to eq @inventory_pools_with_automatic_access.count
  expect(@user.access_rights.pluck(:inventory_pool_id)).to eq @inventory_pools_with_automatic_access.pluck(:id)
  if arg1
    expect(@user.access_rights.where('inventory_pool_id != ?', @current_inventory_pool ).all? {|ar| ar.role == :customer}).to be true
  else
    expect(@user.access_rights.all? {|ar| ar.role == :customer}).to be true
  end
end

Then(/^in my inventory pool the user gets the role 'inventory manager'$/) do
  expect(@user.access_right_for(@current_inventory_pool).role).to eq :inventory_manager
end

Then(/^the newly created user does not have access to that inventory pool$/) do
  expect(@user.access_right_for(@last_edited_inventory_pool)).to eq nil
end

When(/^on the inventory pool I enable the automatic suspension for users with overdue take backs$/) do
  @current_inventory_pool.update_attributes(automatic_suspension: true, automatic_suspension_reason: Faker::Lorem.paragraph)
end

When(/^a user is already suspended for this inventory pool$/) do
  @user = @current_inventory_pool.visits.take_back_overdue.order('RAND()').first.user
  @suspended_until = rand(1.years.from_now..3.years.from_now).to_date
  @suspended_reason = Faker::Lorem.paragraph

  ensure_suspended_user(@user, @current_inventory_pool, @suspended_until, @suspended_reason)
end

Then(/^the existing suspension motivation and the suspended time for this user are not overwritten$/) do
  def checks_suspension
    ar = @user.access_right_for(@current_inventory_pool)
    expect(ar.suspended_until).to eq @suspended_until
    expect(ar.suspended_reason).to eq @suspended_reason
    expect(ar.suspended_reason).not_to eq @current_inventory_pool.automatic_suspension_reason
  end

  checks_suspension
  step 'the cronjob executes the rake task for reminding and suspending all late users'
  checks_suspension
end

When(/^I (enable|disable) "(.*)"$/) do |arg1, arg2|
  b = case arg1
        when 'enable'
          true
        when 'disable'
          false
        else
          raise
      end
  case arg2
    when 'Print contracts'
      find("input[type='checkbox'][name='inventory_pool[print_contracts]']").set b
    when 'Automatic suspension'
      find("input[type='checkbox'][name='inventory_pool[automatic_suspension]']").set b
    when 'Automatic access'
      find("input[type='checkbox'][name='inventory_pool[automatic_access]']").set b
    else
      raise
  end
end

Then(/^"(.*)" is (enabled|disabled)$/) do |arg1, arg2|
  b = case arg2
        when 'enabled'
          true
        when 'disabled'
          false
        else
          raise
      end
  case arg1
    when 'Print contracts'
      expect(@current_inventory_pool.reload.print_contracts).to eq b
    when 'Automatic suspension'
      expect(@current_inventory_pool.reload.automatic_suspension).to eq b
    when 'Automatic access'
      expect(@current_inventory_pool.reload.automatic_access).to eq b
    else
      raise
  end
end

Then(/^I can change the field "(.*?)"$/) do |arg1|
  case arg1
    when 'Min. number of days between order and hand over'
      n = rand(0..14)
      find("input[type='number'][name='inventory_pool[workday_attributes][reservation_advance_days]']").set n
      step 'I save'
      find("input[type='number'][name='inventory_pool[workday_attributes][reservation_advance_days]'][value='#{n}']")
    else
      raise
  end
end

Then(/^I can enter the maximum visits per week day$/) do
  h = {}
  (0..6).each do |i|
    h[i] = rand(0..14)
    find("input[type='number'][name='inventory_pool[workday_attributes][workdays][#{i}][max_visits]']").set h[i]
  end
  step 'I save'
  (0..6).each do |i|
    find("input[type='number'][name='inventory_pool[workday_attributes][workdays][#{i}][max_visits]'][value='#{h[i]}']")
  end
end

When(/^I do not enter a maximum amount of visits on a week day$/) do
  (0..6).each do |i|
    find("input[type='number'][name='inventory_pool[workday_attributes][workdays][#{i}][max_visits]']").set ''
  end
  step 'I save'
end

Then(/^there is no limit of visits for this week day$/) do
  (0..6).each do |i|
    expect(find("input[type='number'][name='inventory_pool[workday_attributes][workdays][#{i}][max_visits]']").value).to be_blank
  end
end
