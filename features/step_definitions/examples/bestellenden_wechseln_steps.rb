# -*- encoding : utf-8 -*-

# Dann /^kann ich die bestellende Person wechseln$/ do
Then(/^I can change who placed this order$/) do
  old_user = @contract.user
  new_user = @current_inventory_pool.users.detect {|u| u.id != old_user.id and u.visits.where.not(status: :submitted).exists? }
  find("#swap-user").click
  within ".modal" do
    find("input#user-id", match: :first).set new_user.name
    find(".ui-menu-item a", match: :first, text: new_user.name).click
    find(".button[type='submit']", match: :first).click
  end
  find(".content-wrapper", :text => new_user.name, match: :first)

  new_contract = new_user.reservations_bundles.find_by(status: :submitted, inventory_pool_id: @contract.inventory_pool)
  @contract.lines.each do |line|
    expect(new_contract.lines.include? line).to be true
  end
  expect{@contract.reload}.to raise_error ActiveRecord::RecordNotFound
end
