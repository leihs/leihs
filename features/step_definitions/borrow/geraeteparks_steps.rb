# -*- encoding : utf-8 -*-  

When(/^I click on the inventory pool link$/) do
  visit borrow_root_path
  find("a[href='#{borrow_inventory_pools_path}']", match: :first).click
end

Then(/^I see the inventory pools I have access to$/) do
  @current_user.inventory_pools.each do |ip|
    expect(has_content?(ip.name)).to be true
  end
end

When(/^I see only inventory pools containing borrowable items$/) do
  expect(all('.row .padding-inset-l > .row > h2.padding-bottom-s').map(&:text)).to eq @current_user.inventory_pools.with_borrowable_items.sort_by {|ip| ip.name}.map(&:to_s)
end

Then(/^I see a description for each inventory pool$/) do
  @current_user.inventory_pools.each do |ip|
    ip.description.split(/\n/).each do |text|
      expect(has_content?(text)).to be true
    end
  end
end

Then(/^the inventory pools are sorted alphabetically on this page$/) do
  expect(all('h2').map(&:text)).to eq all('h2').map(&:text).sort
end
