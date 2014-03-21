# -*- encoding : utf-8 -*-

Angenommen /^ich gebe den Inventarcode eines Gegenstandes der einem Vertrag zugewisen ist in die Suche ein$/ do
  @contract = @current_user.inventory_pools.first.contracts.signed.first
  @item = @contract.items.first
end

Dann /^sehe ich den Vertrag dem der Gegenstand zugewisen ist in der Ergebnisanzeige$/ do
  @current_user.inventory_pools.first.contracts.search(@item.inventory_code).should include @contract
end

Angenommen(/^es existiert ein Benutzer mit Verträgen, der kein Zugriff mehr auf das Gerätepark hat$/) do
  @user = User.find {|u| u.access_rights.find {|ar| ar.inventory_pool == @current_inventory_pool and ar.deleted_at} and !u.contracts.blank?}
  @user.should_not be_nil
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
  line.find(".multibutton").has_no_selector?("li", text: _("Hand Over"), visible: false).should be_true
end
