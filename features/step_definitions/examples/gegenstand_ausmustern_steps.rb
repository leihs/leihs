# encoding: utf-8

def get_scope(item_type)
  case item_type
  when "Gegenstand" then :items
  when "Lizenz" then :licenses
  end
end

Angenommen /^man sucht nach eine(?:m|r) nicht ausgeliehenen (Lizenz|Gegenstand)$/ do |item_type|
  @item = Item.send(get_scope item_type).where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock?}
  step "man befindet sich auf der Editierseite von diesem %s" % item_type
end

Angenommen /^man sucht nach eine(?:m|r) nicht ausgeliehenen (Lizenz|Gegenstand), wo man der Besitzer ist$/ do |item_type|
  @item = Item.send(get_scope item_type).where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not i.retired? and i.is_borrowable? and i.in_stock? and i.owner_id == @current_inventory_pool.id}
  step "man befindet sich auf der Editierseite von diesem %s" % item_type
end

Dann /^kann man diese(?:.?) (?:.*) mit Angabe des Grundes erfolgreich ausmustern$/ do
  field = find("[data-type='field']", text: _("Retirement"))
  field.find("option[value='true']").select_option
  field = find("[data-type='field']", text: _("Reason for Retirement"))
  field.find("textarea").set "test"
  find("#item-save").click
  find("#flash .success")
  @item.reload
  expect(@item.retired).to eq Date.today
  expect(@item.retired_reason).to eq "test"
end

Dann(/^hat man keine Möglichkeit solche(?:.?) (?:.*) auszumustern$/) do
  field = find("[data-type='field']", text: _("Retirement"))
  if field[:"data-editable"] == "true"
    field.find("option[value='true']").select_option
    field = find("[data-type='field']", text: _("Reason for Retirement"))
    field.find("textarea").set "test"
    find("#item-save").click
    step "ich sehe eine Fehlermeldung"
  end
  @item.reload
  expect(@item.retired).to eq nil
end

Dann /^(?:die|der) gerade ausgemusterte (?:.*) verschwindet sofort aus der Inventarliste$/ do
  expect(has_no_content?(@item.inventory_code)).to be true
end

Angenommen /^man sucht nach eine(?:.?) ausgeliehenen (.*)$/ do |item_type|
  @item = Item.send(get_scope item_type).where(inventory_pool_id: @current_inventory_pool.id).detect {|i| not (i.retired? or i.in_stock?)}
  step "man befindet sich auf der Editierseite von diesem %s" % item_type
end

Angenommen /^man sucht nach eine(?:.?) (.*) bei dem ich nicht als Besitzer eingetragen bin$/ do |item_type|
  @item = Item.send(get_scope item_type).where(inventory_pool_id: @current_inventory_pool.id).detect {|i| i.in_stock? and i.owner_id != @current_inventory_pool.id}
  step "man befindet sich auf der Editierseite von diesem %s" % item_type
end

Angenommen /^man gibt bei der Ausmusterung keinen Grund an$/ do
  field = find("[data-type='field']", text: _("Retirement"))
  field.find("option[value='true']").select_option
  field = find("[data-type='field']", text: _("Reason for Retirement"))
  field.find("textarea").set ""
  find("#item-save").click
  step "ich sehe eine Fehlermeldung"
end

Dann /^(?:die|der) (?:.*) ist noch nicht Ausgemustert$/ do
  expect(@item.reload.retired).to eq nil
end

Angenommen(/^man sucht nach eine(?:.) ausgemusterten (.*), wo man der Besitzer ist$/) do |item_type|
  @item = Item.unscoped.send(get_scope item_type).find {|i| i.retired? and i.owner_id == @current_inventory_pool.id}
end

Angenommen(/^man befindet sich auf der Editierseite von diesem (Gegenstand|Lizenz)$/) do |arg1|
  visit manage_edit_item_path(@current_inventory_pool, @item)
end

Wenn(/^man die Ausmusterung bei diese(?:.) (?:.*) zurück setzt$/) do
  expect(has_content?(_("Retirement"))).to be true
  find("[name='item[retired]']").select _("No")
end

Dann(/^wurde man auf die Inventarliste geleitet$/) do
  expect(has_content?(_("List of Inventory"))).to be true
end

Dann(/^diese(?:.?) (?:.*) ist nicht mehr ausgemustert$/) do
  expect(@item.reload.retired?).to be false
end

Wenn(/^die Anschaffungskategorie ist ausgewählt$/) do
  find(".row.emboss", match: :prefer_exact, text: "Anschaffungskategorie").find("select option:not([value=''])", match: :first).select_option if @item.type == "Item"
end

Angenommen(/^man sucht nach eine(?:.) ausgemusterten (.*), wo man der Verantwortliche und nicht der Besitzer ist$/) do |item_type|
  @item = Item.unscoped.send(get_scope item_type).find {|i| i.retired? and i.owner != @current_inventory_pool and i.inventory_pool == @current_inventory_pool}
end
