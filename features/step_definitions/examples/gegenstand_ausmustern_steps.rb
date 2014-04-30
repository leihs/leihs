# encoding: utf-8

Angenommen /^man sucht nach einem nicht ausgeliehenen Gegenstand$/ do
  @item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock?}
  visit manage_edit_item_path @current_inventory_pool, @item
end

Dann /^kann man diesen Gegenstand mit Angabe des Grundes erfolgreich ausmustern$/ do
  field = find("[data-type='field']", text: _("Retirement"))
  field.find("option[value='true']").select_option
  field = find("[data-type='field']", text: _("Reason for Retirement"))
  field.find("textarea").set "test"
  find("#item-save").click
  find("#flash .success")
  @item.reload
  @item.retired.should eq Date.today
  @item.retired_reason.should eq "test"
end

Dann(/^hat man keine Möglichkeit solchen Gegenstand auszumustern$/) do
  field = find("[data-type='field']", text: _("Retirement"))
  if field[:"data-editable"] == "true"
    field.find("option[value='true']").select_option
    field = find("[data-type='field']", text: _("Reason for Retirement"))
    field.find("textarea").set "test"
    find("#item-save").click
    find("#flash .error")
  end
  @item.reload
  @item.retired.should be_nil
end

Dann /^der gerade ausgemusterte Gegenstand verschwindet sofort aus der Inventarliste$/ do
  page.should_not have_content @item.inventory_code
end

Angenommen /^man sucht nach einem ausgeliehenen Gegenstand$/ do
  @item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not (i.retired? or i.in_stock?)}
  visit manage_edit_item_path @current_inventory_pool, @item
end

Angenommen /^man sucht nach einem Gegenstand bei dem ich nicht als Besitzer eingetragen bin$/ do
  @item = Item.where(inventory_pool_id: @current_inventory_pool.id).detect {|i| i.in_stock? and i.owner_id != @current_inventory_pool.id}
  visit manage_edit_item_path @current_inventory_pool, @item
end

Angenommen /^man gibt bei der Ausmusterung keinen Grund an$/ do
  field = find("[data-type='field']", text: _("Retirement"))
  field.find("option[value='true']").select_option
  field = find("[data-type='field']", text: _("Reason for Retirement"))
  field.find("textarea").set ""
  find("#item-save").click
  find("#flash .error")
end

Dann /^der Gegenstand ist noch nicht Ausgemustert$/ do
  @item.reload.retired.should be_nil
end

Angenommen(/^man sucht nach einem ausgemusterten Gegenstand, wo man der Besitzer ist$/) do
  @item = Item.unscoped.find {|i| i.retired? and i.owner_id == @current_inventory_pool.id}
end

Angenommen(/^man befindet sich auf der Gegenstandseditierseite dieses Gegenstands$/) do
  visit manage_edit_item_path(@current_inventory_pool, @item)
end

Wenn(/^man die Ausmusterung bei diesem Gegenstand zurück setzt$/) do
  page.has_content?(_("Retirement")).should be_true
  find("*[name='item[retired]']").select _("No")
end

Dann(/^wurde man auf die Inventarliste geleitet$/) do
  page.has_content?(_("List of Inventory")).should be_true
end

Dann(/^dieses Gegenstand ist nicht mehr ausgemustert$/) do
  @item.reload.should_not be_retired
  sleep(0.33) # fix lazy request problem
end

Wenn(/^die Anschaffungskategorie ist ausgewählt$/) do
  find(".row.emboss", match: :prefer_exact, text: "Anschaffungskategorie").find("select option:not([value=''])", match: :first).select_option
end

Angenommen(/^man sucht nach einem ausgemusterten Gegenstand, wo man der Verantwortliche und nicht der Besitzer ist$/) do
  @item = Item.unscoped.find {|i| i.retired? and i.owner != @current_inventory_pool and i.inventory_pool == @current_inventory_pool}
end
