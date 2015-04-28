# -*- encoding : utf-8 -*-

#Angenommen /^ich gebe den Inventarcode eines Gegenstandes der einem Vertrag zugewisen ist in die Suche ein$/ do
Given /^I search for the inventory code of an item that is in a contract$/ do
  @contract = @current_user.inventory_pools.first.reservations_bundles.signed.first
  @item = @contract.items.first
end

#Dann /^sehe ich den Vertrag dem der Gegenstand zugewisen ist in der Ergebnisanzeige$/ do
Then /^I see the contract this item is assigned to in the list of results$/ do
  expect(@current_user.inventory_pools.first.reservations_bundles.search(@item.inventory_code)).to include @contract
end

#Angenommen(/^es existiert ein Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat$/) do
Given(/^there is a user with contracts who no longer has access to the current inventory pool$/) do
  @user = User.find {|u| u.access_rights.find {|ar| ar.inventory_pool == @current_inventory_pool and ar.deleted_at} and !u.reservations_bundles.blank?}
  expect(@user).not_to be_nil
end

# Hey, this is duplicated!
#Wenn(/^man nach dem Benutzer sucht$/) do
#When(/^I search for that user$/) do
#  search_field = find("#topbar-search input#search_term")
#  search_field.set @user.name
#  search_field.native.send_key :return
#end

#Dann(/^sieht man alle Veträge des Benutzers$/) do
Then(/^I see all that user's contracts$/) do
  @user.reservations_bundles.each {|c| find("#contracts .line[data-id='#{c.id}']") }
end

#Dann(/^sieht man alle unterschriebenen und geschlossenen Veträge des Benutzers$/) do
Then(/^I see that user's signed and closed contracts$/) do
  @user.reservations_bundles.signed_or_closed.where(inventory_pool: @current_inventory_pool).each {|c| find("#contracts .line[data-id='#{c.id}']") }
end

#Dann(/^der Name des Benutzers ist in jeder Vertragslinie angezeigt$/) do
Then(/^the name of that user is shown on each contract line$/) do
  within '#contracts' do
    all('.line').each {|el| el.text.include? @user.name }
  end
end

#Dann(/^die Personalien des Benutzers werden im Tooltip angezeigt$/) do
Then(/^that user's personal details are shown in the tooltip$/) do
  hover_for_tooltip find("#contracts [data-type='user-cell']", match: :first)
  within '.tooltipster-base' do
    [@user.name, @user.email, @user.address, @user.phone, @user.badge_id].each {|info| has_content? info}
  end
end

#Angenommen(/^es gibt einen Benutzer, mit einer nicht genehmigter Bestellung$/) do
Given(/^there is a user with an unapproved order$/) do
  @user = @current_inventory_pool.users.find {|u| u.reservations_bundles.submitted.exists? }
end

#Wenn(/^man nach diesem Benutzer sucht$/) do
When(/^I search for that user$/) do
  within '#search' do
    find('input#search_term').set @user.name
    find("button[type='submit']").click
  end
end

#Dann(/^kann ich die nicht genehmigte Bestellung des Benutzers nicht aushändigen ohne sie vorher zu genehmigen$/) do
Then(/^I cannot hand over the unapproved order unless I approve it first$/) do
  contract = @user.reservations_bundles.submitted.first
  line = find(".line[data-id='#{contract.id}']")
  expect(line.find('.multibutton').has_no_selector?('li', text: _('Hand Over'), visible: false)).to be true
end

#Angenommen(/^es existiert ein Benutzer mit mindestens (\d+) und weniger als (\d+) Verträgen$/) do |min, max|
Given(/^there is a user with at least (\d+) and less than (\d+) contracts$/) do |min, max|
  @user = @current_inventory_pool.users.find do |u|
    u.reservations_bundles.signed_or_closed.where(inventory_pool: @current_inventory_pool).to_a.count.between? min.to_i, max.to_i # NOTE count returns a Hash because the group() in default scope
  end
  expect(@user).not_to be_nil
end

#Dann(/^man sieht keinen Link 'Zeige alle gefundenen Verträge'$/) do
Then(/^I don't see a link labeled 'Show all matching contracts'$/) do
  expect(has_no_selector?("#contracts [data-type='show-all']")).to be true
end

Given(/^there is a "(.*?)" item in my inventory pool$/) do |arg1|
  items = @current_inventory_pool.items
  @item = case arg1
          when 'Broken'
            items.find &:is_broken
          when 'Retired'
            items.find &:retired
          when 'Incomplete'
            items.find &:is_incomplete
          when 'Unborrowable'
            items.find {|i| not i.is_borrowable}
          end
  expect(@item).not_to be_nil
end

When(/^I search globally after this item with its inventory code$/) do
  within '#topbar #search' do
    find('input#search_term').set @item.inventory_code
    find("button[type='submit']").click
  end
end

Then(/^I see the item in the items container$/) do
  expect(find('#items')).to have_selector(".line[data-type='item']", text: @item.inventory_code)
end

Given(/^there exists a closed contract with a retired item$/) do
  @contract = @current_inventory_pool.reservations_bundles.closed.find do |c|
    @item = c.items.find &:retired
  end
  expect(@contract).not_to be_nil
end

#Then(/^sehe den Gegenstand ihn im Gegenstände\-Container$/) do
Then(/^I see the item in the items area$/) do
  find('#items .line', text: @item.inventory_code)
end

Then(/^I hover over the list of items on the contract line$/) do
  find("#contracts .line [data-type='lines-cell']", match: :first).hover
end

Then(/^I see in the tooltip the model of this item$/) do
  find('.tooltipster-base', text: @item.model.name)
end

Given(/^there exists a closed contract with an item, for which an other inventory pool is responsible and owner$/) do
  @contract = @current_inventory_pool.reservations_bundles.closed.find do |c|
    @item = c.items.find {|i| i.inventory_pool != @current_inventory_pool and i.owner != @current_inventory_pool }
  end
  expect(@contract).not_to be_nil
end

Then(/^I do not see the items container$/) do
  expect(page).to have_no_selector '#items'
end
