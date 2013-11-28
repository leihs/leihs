# -*- encoding : utf-8 -*-

Angenommen /^ich gebe den Inventarcode eines Gegenstandes der einem Vertrag zugewisen ist in die Suche ein$/ do
  @contract = @current_user.inventory_pools.first.contracts.signed.first
  @item = @contract.items.first
end

Dann /^sehe ich den Vertrag dem der Gegenstand zugewisen ist in der Ergebnisanzeige$/ do
  @current_user.inventory_pools.first.contracts.search(@item.inventory_code).should include @contract
end

Angenommen(/^es existiert ein Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat$/) do
  @user = User.find {|u| u.all_access_rights.find {|ar| ar.inventory_pool == @current_inventory_pool and ar.deleted_at} and !u.contracts.blank?}
end

Wenn(/^man nach dem Benutzer sucht$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @user.name
  search_field.native.send_key :return
end

Dann(/^sieht man alle Veträge des Benutzers$/) do
  @user.contracts.each {|c| find("#contracts .line[data-id='#{c.id}']") }
end

Dann(/^der Name des Benutzers ist in jeder Vertragslinie angezeigt$/) do
  all("#contracts .line").each {|el| el.text.include? @user.name }
end

Dann(/^die Personalien des Benutzers werden im Tooltip angezeigt$/) do
  hover_for_tooltip find("#contracts [data-type='user-cell']")
  within ".tooltipster-base" do
    [@user.name, @user.email, @user.address, @user.phone, @user.badge_id].each {|info| has_content? info}
  end
end
