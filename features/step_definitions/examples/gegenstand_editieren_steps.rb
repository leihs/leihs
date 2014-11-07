# -*- encoding : utf-8 -*-

Angenommen /^man editiert einen Gegenstand, wo man der Besitzer ist(, der am Lager)?( und in keinem Vertrag vorhanden ist)?$/ do |arg1, arg2|
  items = @current_inventory_pool.items.items.where(owner_id: @current_inventory_pool, models: {is_package: false})
  items = items.in_stock if arg1
  items = items.select {|i| ContractLine.where(item_id: i.id).empty?} if arg2

  @item = items.sample

  visit manage_edit_item_path @current_inventory_pool, @item
  expect(has_selector?(".row.emboss")).to be true
end

Dann /^muss der "(.*?)" unter "(.*?)" ausgewählt werden$/ do |key, section|
  field = find("[data-type='field']", text: key)
  expect(field[:"data-required"]).to eq "true"
end

Wenn /^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" angegeben werden$/ do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.find("label,option", match: :first, :text => value).click
  newfield = find("[data-type='field']", text: newkey)
  expect(newfield[:"data-required"]).to eq "true"
end

Dann /^sind alle Pflichtfelder mit einem Stern gekenzeichnet$/ do
  all(".field[data-required='true']", :visible => true).each do |field|
    expect(field.text[/\*/]).not_to be_nil
  end
  all(".field:not([data-required='true'])").each do |field|
    expect(field.text[/\*/]).to eq nil
  end
end

Wenn /^ein Pflichtfeld nicht ausgefüllt\/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern$/ do
  find(".field[data-required='true'] textarea", match: :first).set("")
  find(".field[data-required='true'] input[type='text']", match: :first).set("")
  find("#item-save").click
  step "ich sehe eine Fehlermeldung"
  expect(@item.to_json).to eq @item.reload.to_json
end

Wenn /^die nicht ausgefüllten\/ausgewählten Pflichtfelder sind rot markiert$/ do
  all(".field[data-required='true']", :visible => true).each do |field|
    if field.all("input[type=text]").any? { |input| input.value == 0 } or
        field.all("textarea").any? { |textarea| textarea.value == 0 } or
        (ips = field.all("input[type=radio]"); ips.all? { |input| not input.checked? } if not ips.empty?)
      expect(field[:class][/invalid/]).not_to be_nil
    end
  end
end

Dann /^sehe ich die Felder in folgender Reihenfolge:$/ do |table|
  values = table.raw.map do |x|
    x.first.gsub(/^\-\ |\ \-$/, '')
  end
  expect(page.text).to match Regexp.new(values.join('.*'), Regexp::MULTILINE)
end

Wenn(/^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" ausgewählt werden$/) do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.find("option", match: :first, :text => value).select_option
  newfield = find("[data-type='field']", text: newkey)
  expect(newfield[:"data-required"]).to eq "true"
end

Dann(/^ist der Gegenstand mit all den angegebenen Informationen gespeichert$/) do
  find(:select, "retired").first("option").select_option if @table_hashes.detect { |r| r["Feldname"] == "Ausmusterung" } and (@table_hashes.detect { |r| r["Feldname"] == "Ausmusterung" }["Wert"]) == "Ja"
  step %Q(ich nach "%s" suche) %  (@table_hashes.detect { |r| r["Feldname"] == "Inventarcode" }["Wert"])
  find(".line", :text => @table_hashes.detect { |r| r["Feldname"] == "Modell" }["Wert"], :visible => true)
  step "man befindet sich auf der Editierseite von diesem Gegenstand"
  step 'hat der Gegenstand alle zuvor eingetragenen Werte'
end

Wenn(/^ich den Lieferanten lösche$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Supplier")).find("input").set ""
end

Dann(/^wird der neue Lieferant gelöscht$/) do
  expect(has_content?(_("List of Inventory"))).to be true
  expect(Supplier.find_by_name(@new_supplier)).not_to be_nil
end

Dann(/^ist bei dem bearbeiteten Gegenstand keiner Lieferant eingetragen$/) do
  expect(has_content?(_("List of Inventory"))).to be true
  expect(@item.reload.supplier).to eq nil
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes mit gesetztem Lieferanten$/) do
  @item = @current_inventory_pool.items.find { |i| not i.supplier.nil? }
  step "man befindet sich auf der Editierseite von diesem Gegenstand"
end

Wenn(/^ich den Lieferanten ändere$/) do
  @supplier = Supplier.first
  fill_in_autocomplete_field _("Supplier"), @supplier.name
end

Dann(/^ist bei dem bearbeiteten Gegestand der geänderte Lieferant eingetragen$/) do
  expect(@item.reload.supplier).to eq @supplier
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist und wo man Besitzer ist$/) do
  @item = @current_inventory_pool.own_items.not_in_stock.sample
  @item_before = @item.to_json
  step "man befindet sich auf der Editierseite von diesem Gegenstand"
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist$/) do
  @item = @current_inventory_pool.items.not_in_stock.sample
  @item_before = @item.to_json
  step "man befindet sich auf der Editierseite von diesem Gegenstand"
end

Wenn(/^ich die verantwortliche Abteilung ändere$/) do
  fill_in_autocomplete_field _("Responsible"), InventoryPool.where("id != ?", @item.inventory_pool.id).sample.name
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der in einem Vertrag vorhanden ist$/) do
  @item = @current_inventory_pool.items.items.not_in_stock.sample
  @item_before = @item.to_json
  step "man befindet sich auf der Editierseite von diesem Gegenstand"
end

Wenn(/^ich das Modell ändere$/) do
  fill_in_autocomplete_field _("Model"), @current_inventory_pool.models.select { |m| m != @item.model }.sample.name
end

Wenn(/^ich den Gegenstand ausmustere$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Retirement")).find("select", match: :first).select _("Yes")
  find(".row.emboss", match: :prefer_exact, text: _("Reason for Retirement")).find("input, textarea", match: :first).set "Retirement reason"
end

Angenommen(/^there is a model without a version$/) do
  @model = Model.find { |m| !m.version }
  expect(@model).not_to be_nil
end

Wenn(/^I assign this model to the item$/) do
  fill_in_autocomplete_field _("Model"), @model.name
end

Dann(/^there is only product name in the input field of the model$/) do
  expect(find("input[data-autocomplete_value_target='item[model_id]']").value).to eq @model.product
end
