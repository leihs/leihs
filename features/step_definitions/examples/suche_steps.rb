# -*- encoding : utf-8 -*-

Angenommen /^ich gebe den Inventarcode eines Gegenstandes der einem Vertrag zugewisen ist in die Suche ein$/ do
  @contract = @current_user.inventory_pools.first.contracts.signed.first
  @item = @contract.items.first
end

Dann /^sehe ich den Vertrag dem der Gegenstand zugewisen ist in der Ergebnisanzeige$/ do
  expect(@current_user.inventory_pools.first.contracts.search(@item.inventory_code)).to include @contract
end

Angenommen(/^es existiert ein Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat$/) do
  @user = User.find {|u| u.access_rights.find {|ar| ar.inventory_pool == @current_inventory_pool and ar.deleted_at} and !u.contracts.blank?}
  expect(@user).not_to be_nil
end

Wenn(/^man nach dem Benutzer sucht$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @user.name
  search_field.native.send_key :return
end

Dann(/^sieht man alle Veträge des Benutzers$/) do
  @user.contracts.each {|c| find("#contracts .line[data-id='#{c.id}']") }
end

Dann(/^sieht man alle unterschriebenen und geschlossenen Veträge des Benutzers$/) do
  @user.contracts.signed_or_closed.where(inventory_pool: @current_inventory_pool).each {|c| find("#contracts .line[data-id='#{c.id}']") }
end

Dann(/^der Name des Benutzers ist in jeder Vertragslinie angezeigt$/) do
  within "#contracts" do
    all(".line").each {|el| el.text.include? @user.name }
  end
end

Dann(/^die Personalien des Benutzers werden im Tooltip angezeigt$/) do
  hover_for_tooltip find("#contracts [data-type='user-cell']", match: :first)
  within ".tooltipster-base" do
    [@user.name, @user.email, @user.address, @user.phone, @user.badge_id].each {|info| has_content? info}
  end
end

Angenommen(/^es gibt einen Benutzer, mit einer nicht genehmigter Bestellung$/) do
  @user = @current_inventory_pool.users.find {|u| u.contracts.submitted.exists? }
end

Wenn(/^man nach diesem Benutzer sucht$/) do
  within "#search" do
    find("input#search_term").set @user.name
    find("button[type='submit']").click
  end
end

Dann(/^kann ich die nicht genehmigte Bestellung des Benutzers nicht aushändigen ohne sie vorher zu genehmigen$/) do
  contract = @user.contracts.submitted.first
  line = find(".line[data-id='#{contract.id}']")
  expect(line.find(".multibutton").has_no_selector?("li", text: _("Hand Over"), visible: false)).to be true
end

Angenommen(/^es existiert ein Benutzer mit mindestens (\d+) und weniger als (\d+) Verträgen$/) do |min, max|
  @user = @current_inventory_pool.users.find {|u| u.contracts.signed_or_closed.where(inventory_pool: @current_inventory_pool).count.between? min.to_i, max.to_i}
  expect(@user).not_to be_nil
end

Dann(/^man sieht keinen Link 'Zeige alle gefundenen Verträge'$/) do
  expect(has_no_selector?("#contracts [data-type='show-all']")).to be true
end

Given(/^there is a "(.*?)" item in my inventory pool$/) do |arg1|
  items = @current_inventory_pool.items
  @item = case arg1
          when "Defekt"
            items.find &:is_broken
          when "Ausgemustert"
            items.find &:retired
          when "Unvollständig"
            items.find &:is_incomplete
          when "Nicht ausleihbar"
            items.find {|i| not i.is_borrowable}
          end
  expect(@item).not_to be_nil
end

When(/^I search globally after this item with its inventory code$/) do
  within "#topbar #search" do
    find("input#search_term").set @item.inventory_code
    find("button[type='submit']").click
  end
end

Then(/^I see the item in the items container$/) do
  expect(find("#items")).to have_selector(".line[data-type='item']", text: @item.inventory_code)
end

Given(/^there exists a closed contract with a retired item$/) do
  @contract = @current_inventory_pool.contracts.closed.find do |c|
    @item = c.items.find &:retired
  end
  expect(@contract).not_to be_nil
end

Then(/^sehe den Gegenstand ihn im Gegenstände\-Container$/) do
  find("#items .line", text: @item.inventory_code)
end

Then(/^I hover over the list of items on the contract line$/) do
  find("#contracts .line [data-type='lines-cell']", match: :first).hover
end

Then(/^I see in the tooltip the model of this item$/) do
  find(".tooltipster-base", text: @item.model.name)
end

Given(/^there exists a closed contract with an item, for which an other inventory pool is responsible and owner$/) do
  @contract = @current_inventory_pool.contracts.closed.find do |c|
    @item = c.items.find {|i| i.inventory_pool != @current_inventory_pool and i.owner != @current_inventory_pool }
  end
  expect(@contract).not_to be_nil
end

Then(/^I do not see the items container$/) do
  expect(page).to have_no_selector "#items"
end
