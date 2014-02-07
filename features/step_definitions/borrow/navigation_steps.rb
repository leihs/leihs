# -*- encoding : utf-8 -*-

Dann(/^seh ich die Navigation$/) do
  find("nav", match: :first)
end

Dann(/^die Navigation beinhaltet "(.*?)"$/) do |section|
  case section
    when "Abzuholen"
      find("nav a[href='#{borrow_to_pick_up_path}']") if @current_user.contract_lines.to_hand_over.sum(&:quantity) > 0
    when "Rückgaben"
      find("nav a[href='#{borrow_returns_path}']") if @current_user.contract_lines.to_take_back.sum(&:quantity) > 0
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
      pending
  end
end

Dann(/^seh ich in der Navigation den Home\-Button$/) do
  find("nav a[href='#{borrow_root_path}']", match: :first)
end

Wenn(/^ich den Home\-Button bediene$/) do
  find("nav a[href='#{borrow_root_path}']", match: :first).click
end

Dann(/^lande ich auf der Seite der Hauptkategorien$/) do
  current_path.should == borrow_root_path
end

When(/^man befindet sich im Verwalten\-Bereich$/) do
  visit manage_root_path
end

Und(/^man befindet sich im Verleih\-Bereich$/) do
  @current_inventory_pool = @current_user.managed_inventory_pools(:group_manager).sample
  visit manage_daily_view_path(@current_inventory_pool)
end

Und(/^die Navigation beinhaltet nur die Bestellungen$/) do
  within("#contracts-index-view > .row:nth-child(1) > nav:nth-child(1) ul") do
    all("li").size.should == 1
    find("li", text: _("Orders"))
  end
end

Dann(/^man sieht die Gerätepark\-Auswahl im Verwalten\-Bereich$/) do
  within("#contracts-index-view > .row:nth-child(1) > nav:nth-child(2) .dropdown-holder") do
    find("div[title]", match: :prefer_exact, text: @current_inventory_pool.name)
  end
end
