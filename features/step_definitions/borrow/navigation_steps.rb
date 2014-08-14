# -*- encoding : utf-8 -*-

Dann(/^seh ich die Navigation$/) do
  find("nav", match: :first)
end

Dann(/^die Navigation beinhaltet "(.*?)"$/) do |section|
  case section
    when "Abzuholen"
      find("nav a[href='#{borrow_to_pick_up_path}']") if @current_user.contract_lines.to_hand_over.to_a.sum(&:quantity) > 0
    when "Rückgaben"
      find("nav a[href='#{borrow_returns_path}']") if @current_user.contract_lines.to_take_back.to_a.sum(&:quantity) > 0
    when "Bestellungen"
      find("nav a[href='#{borrow_orders_path}']") if @current_user.contracts.submitted.count > 0
    when "Geräteparks"
      find("nav a[href='#{borrow_inventory_pools_path}']", :text => _("Inventory Pools"))
    when "Benutzer"
      find("nav a[href='#{borrow_current_user_path}']", :text => @current_user.short_name)
    when "Logout"
      find("nav a[href='#{logout_path}']")
    when "Verwalten"
      find("nav a[href='#{manage_root_path}']", :text => _("Manage"))
    when "Verleih"
      find("nav a[href='#{manage_daily_view_path(@current_inventory_pool)}']", :text => _("Lending"))
    when "Ausleihen"
      find("nav a[href='#{borrow_root_path}']", :text => _("Borrow"))
    else
      raise "not found"
  end
end

Dann(/^seh ich in der Navigation den Home\-Button$/) do
  find("nav a[href='#{borrow_root_path}']", match: :first)
end

Wenn(/^ich den Home\-Button bediene$/) do
  find("nav a[href='#{borrow_root_path}']", match: :first).click
end

Dann(/^lande ich auf der Seite der Hauptkategorien$/) do
  expect(current_path).to eq borrow_root_path
end

When(/^I visit the lending section$/) do
  visit manage_daily_view_path(@current_inventory_pool)
end

Und(/^die Navigation beinhaltet nur die Bestellungen$/) do
  within("#contracts-index-view > .row:nth-child(1) > nav:nth-child(1) ul") do
    expect(all("li").size).to eq 1
    find("li", text: _("Orders"))
  end
end

Dann(/^man sieht die Gerätepark\-Auswahl im Verwalten\-Bereich$/) do
  find("[data-target='#ip-dropdown-menu']", text: @current_inventory_pool.name)
end

When(/^I visit the lending section on the list of (all|open|closed) contracts$/) do |arg1|
  visit manage_contracts_path(@current_inventory_pool, status: [:signed, :closed])
  case arg1
    when "all"
    when "open"
      find("#list-tabs a.inline-tab-item", text: _("Open")).click
    when "closed"
      find("#list-tabs a.inline-tab-item", text: _("Closed")).click
    else
      raise "not found"
  end
  find("#contracts.list-of-lines .line", match: :first)
end

Then(/^I see at least (an order|a contract)$/) do |arg1|
  case arg1
    when "an order"
      find("#orders.list-of-lines .line", match: :first)
    when "a contract"
      find("#contracts.list-of-lines .line", match: :first)
    else
      raise "not found"
  end
end
