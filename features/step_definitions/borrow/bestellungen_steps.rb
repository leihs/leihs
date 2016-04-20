# -*- encoding : utf-8 -*-

Then(/^I see the number of submitted, unapproved orders on every page$/) do
  [borrow_root_path,
   borrow_inventory_pools_path,
   borrow_current_order_path,
   borrow_current_user_path].each do |path|
    visit path
    expect(find("nav a[href='#{borrow_orders_path}'] .badge", match: :first).text.to_i).to eq @current_user.reservations_bundles.submitted.to_a.size  # NOTE count returns a Hash because the group() in default scope
  end
end

When(/^I am listing my orders$/) do
  visit borrow_root_path
  find("nav a[href='#{borrow_orders_path}']", match: :first).click
end

Then(/^I see my submitted, unapproved orders$/) do
  @current_user.reservations_bundles.submitted.each do |contract|
    expect(has_content?(contract.inventory_pool.name)).to be true
  end
end

Then(/^I see the information that the order has not yet been approved$/) do
  expect(has_content?(_('These orders have been successfully submitted, but are NOT YET APPROVED.'))).to be true
end

Then(/^the orders are sorted by date and inventory pool$/) do
  titles = all('.row.padding-inset-l').map {|x| [Date.parse(x.find('h3', match: :first).text), x.find('h2', match: :first).text]}
  expect(titles.empty?).to be false
  expect(titles.sort == titles).to be true
end

Then(/^each order shows the items to approve$/) do
  @current_user.reservations.submitted.each do |line|
    find('.line', match: :prefer_exact, text: line.model.name)
  end
end

Then(/^the items in the order are sorted alphabetically and by model name$/) do
  all('.separated-top').each do |block|
    names = block.all('.line').map {|x| x.text.split("\n")[1]}
    expect(names.sort == names).to be true
  end
end

