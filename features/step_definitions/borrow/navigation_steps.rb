# -*- encoding : utf-8 -*-

#Dann(/^seh ich die Navigation$/) do
Then(/^I can see the navigation bars$/) do
  find("nav", match: :first)
end

#Dann(/^die Navigation beinhaltet "(.*?)"$/) do |section|
Then(/^the navigation contains "(.*?)"$/) do |section|
  case section
    when "To pick up"
      find("nav a[href='#{borrow_to_pick_up_path}']") if @current_user.contract_lines.approved.to_a.sum(&:quantity) > 0
    when "To return"
      find("nav a[href='#{borrow_returns_path}']") if @current_user.contract_lines.signed.to_a.sum(&:quantity) > 0
    when "Orders"
      find("nav a[href='#{borrow_orders_path}']") if @current_user.contract_lines.submitted.count > 0
    when "Inventory pools"
      find("nav a[href='#{borrow_inventory_pools_path}']", :text => _("Inventory Pools"))
    when "User"
      find("nav a[href='#{borrow_current_user_path}']", :text => @current_user.short_name)
    when "Log out"
      find("nav a[href='#{logout_path}']")
    when "Manage"
      find("nav a[href='#{manage_root_path}']", :text => _("Manage"))
    when "Lending"
      find("nav a[href='#{manage_daily_view_path(@current_inventory_pool)}']", :text => _("Lending"))
    when "Borrow"
      find("nav a[href='#{borrow_root_path}']", :text => _("Borrow"))
    else
      raise
  end
end

#Dann(/^seh ich in der Navigation den Home\-Button$/) do
Then(/^I see a home button in the navigation bars$/) do
  find("nav a[href='#{borrow_root_path}']", match: :first)
end

#Wenn(/^ich den Home\-Button bediene$/) do
When(/^I use the home button$/) do
  find("nav a[href='#{borrow_root_path}']", match: :first).click
end

#Dann(/^lande ich auf der Seite der Hauptkategorien$/) do
#  expect(current_path).to eq borrow_root_path
#end

When(/^I visit the lending section$/) do
  visit manage_daily_view_path(@current_inventory_pool)
end

Dann(/^man sieht die Gerätepark\-Auswahl im Verwalten\-Bereich$/) do
  find("[data-target='#ip-dropdown-menu']", text: @current_inventory_pool.name)
end

When(/^I visit the lending section on the list of (all|open|closed) contracts$/) do |arg1|
  visit manage_contracts_path(@current_inventory_pool, status: [:signed, :closed])
  step %Q(Then I can view "#{arg1}" contracts)
  find("#contracts.list-of-lines .line", match: :first)
end

Then(/^I see at least (an order|a contract)$/) do |arg1|
  case arg1
    when "an order"
      find("#orders.list-of-lines .line", match: :first)
    when "a contract"
      find("#contracts.list-of-lines .line", match: :first)
    else
      raise
  end
end


When(/^I open the tab "(.*?)"$/) do |arg1|
  within("#contracts-index-view > .row:nth-child(1) > nav:nth-child(1) ul") do
    find("li a", text: _(arg1)).click
  end

  s1 = case arg1
         when "Orders"
           _("List of Orders")
         when "Contracts"
           _("List of Contracts")
         else
           raise
       end

  within("#contracts-index-view") do
    find(".headline-xl", text: s1)
    find("#contracts")
  end
end

Then(/^I see the tabs:$/) do |table|
  table.raw.flatten do |tab|
    find("#list-tabs a.inline-tab-item", text: tab)
  end
end

Then(/^the checkbox "(.*?)" is already checked and I can uncheck$/) do |arg1|
  case arg1
    when "To be verified"
      find("input[type='checkbox'][name='to_be_verified']:checked").click
      within("#contracts-index-view") do
        find("#contracts")
      end
    when "No verification required"
      find("input[type='checkbox'][name='no_verification_required']:checked").click
      within("#contracts-index-view") do
        find("#contracts")
      end
    else
      raise
  end
end

Then(/^I can view "(.*?)" contracts$/) do |arg1|
  find("#list-tabs a.inline-tab-item", text: _(arg1.capitalize)).click
  find("#contracts.list-of-lines")
end

