# -*- encoding : utf-8 -*-

Dann /^kann ich die bestellende Person wechseln$/ do
  old_user = @contract.user
  new_user = @current_inventory_pool.users.detect {|u| u.id != old_user.id and u.visits.size > 0}
  find("#swap-user").click
  within ".modal" do
    find("input#user-id", match: :first).set new_user.name
    find(".ui-menu-item a", match: :first, text: new_user.name).click
    find(".button[type='submit']", match: :first).click
  end
  find(".content-wrapper", :text => new_user.name, match: :first)
  expect(@contract.reload.user.id).to eq new_user.id
end
