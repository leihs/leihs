# encoding: utf-8

Given(/^there is an order with two different time windows$/) do
  @customer = @current_inventory_pool.users.customers.order('RAND()').first
  FactoryGirl.create :reservation, user: @customer, status: :submitted, inventory_pool: @current_inventory_pool, start_date: Date.today, end_date: Date.tomorrow
  FactoryGirl.create :reservation, user: @customer, status: :submitted, inventory_pool: @current_inventory_pool, start_date: Date.today, end_date: Date.today+10.days
  @contract = @customer.reservations_bundles.submitted.find_by(inventory_pool_id: @current_inventory_pool)
end

Then(/^I see the longest time span of this order directly on the order's line$/) do
  line_with_max_range = @contract.item_lines.max{|line| line.end_date - line.start_date}
  range = (line_with_max_range.end_date-line_with_max_range.start_date).to_i+1
  expect(find(".line[data-id='#{@contract.id}']").has_content? "#{range} #{_('days')}").to be true
end

When(/^the current inventory pool's users are suspended$/) do
  @current_inventory_pool.users.customers.each do |user|
    ensure_suspended_user(user, @current_inventory_pool)
  end
end

When(/^the current inventory pool has at least suspended (\d+) users?$/) do |n|
  n.to_i.times do
    user = @hand_over.user.delegated_users.order('RAND()').first
    ensure_suspended_user(user, @current_inventory_pool)
  end
end

Then(/^each line of this user contains the text 'Suspended'$/) do
  find("[data-type='user-cell'] span.darkred-text", match: :first)
  all("[data-type='user-cell']").each do |line|
    line.find('span.darkred-text', text: '%s!' % _('Suspended'))
  end
end
