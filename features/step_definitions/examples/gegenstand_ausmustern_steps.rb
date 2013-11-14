# encoding: utf-8

Angenommen /^man sucht nach einem nicht ausgeliehenen Gegenstand$/ do
  @unretired_item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock?}
  fill_in 'list-search', with: @unretired_item.model.name
  within("#inventory") do
    find(".line[data-type='model']", match: :prefer_exact, text: @unretired_item.model.name).find(".button[data-type='inventory-expander']").click
    within(".group-of-lines .line[data-type='item']", text: @unretired_item.inventory_code) do
      find(".multibutton .dropdown-holder").hover
      find(".dropdown-item", :text => _("Retire Item")).click
    end
  end
end

Dann /^kann man diesen Gegenstand mit Angabe des Grundes erfolgreich ausmustern$/ do
  fill_in "retired_reason", with: "test"
  click_button _("Retire")
  step "ensure there are no active requests"
  @unretired_item.reload
  @unretired_item.retired.should eq Date.today
  @unretired_item.retired_reason.should eq "test"
end

Dann /^der gerade ausgemusterte Gegenstand verschwindet sofort aus der Inventarliste$/ do
  page.should_not have_content @unretired_item.inventory_code
end

Angenommen /^man sucht nach einem ausgeliehenen Gegenstand$/ do
  @borrowed_item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not (i.retired? or i.in_stock?)}
  fill_in 'list-search', with: @borrowed_item.model.name
  find(".line[data-type='model']", match: :prefer_exact, text: @borrowed_item.model.name).find(".button[data-type='inventory-expander']")
end

Dann /^hat man keine Möglichkeit übers Interface solchen Gegenstand auszumustern$/ do
  item = @borrowed_item || @unborrowed_item_not_the_owner
  within("#inventory") do
    find(".line[data-type='model']", match: :prefer_exact, text: item.model.name).find(".button[data-type='inventory-expander']").click
    within(".group-of-lines .line[data-type='item']", text: item.inventory_code) do
      find(".multibutton .dropdown-holder").hover
      page.should_not have_selector(".dropdown-item", :text => _("Retire Item"))
    end
  end
end

Angenommen /^man sucht nach einem Gegenstand bei dem ich nicht als Besitzer eingetragen bin$/ do
  @unborrowed_item_not_the_owner = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| i.in_stock? and i.owner_id != @current_inventory_pool.id}
  fill_in 'list-search', with: @unborrowed_item_not_the_owner.model.name
  find(".line[data-type='model']", match: :prefer_exact, text: @unborrowed_item_not_the_owner.model.name).find(".button[data-type='inventory-expander']")
end

Angenommen /^man gibt bei der Ausmusterung keinen Grund an$/ do
  click_button _("Retire")
  step "ensure there are no active requests"
  @unretired_item.reload
end

Dann /^der Gegenstand ist noch nicht Ausgemustert$/ do
  @unretired_item.retired.should be_nil
end

Angenommen(/^man sucht nach einem ausgemusterten Gegenstand, wo man der Besitzer ist$/) do
  @retired_item = Item.unscoped.find {|i| i.retired? and i.owner_id == @current_inventory_pool.id}
end

Angenommen(/^man befindet sich auf der Gegenstandseditierseite dieses Gegenstands$/) do
  visit "/manage/%d/items/%d" % [@current_inventory_pool.id, @retired_item.id]
  page.has_content?(@retired_item.model.name).should be_true
end

Wenn(/^man die Ausmusterung bei diesem Gegenstand zurück setzt$/) do
  page.has_content?(_("Retirement")).should be_true
  find("*[name='item[retired]']").select _("No")
end

Dann(/^wurde man auf die Inventarliste geleitet$/) do
  page.has_content?(_("List of Inventory")).should be_true
end

Dann(/^dieses Gegenstand ist nicht mehr ausgemustert$/) do
  @retired_item.reload.should_not be_retired
end

Wenn(/^die Anschaffungskategorie ist ausgewählt$/) do
  find(".row.emboss", match: :prefer_exact, text: "Anschaffungskategorie").find("select option:not([value=''])", match: :first).select_option
end

Angenommen(/^man sucht nach einem ausgemusterten Gegenstand, wo man der Verantwortliche und nicht der Besitzer ist$/) do
  @retired_item = Item.unscoped.find {|i| i.retired? and i.owner != @current_inventory_pool and i.inventory_pool == @current_inventory_pool}
end
