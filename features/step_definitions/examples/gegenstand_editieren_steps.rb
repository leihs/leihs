# -*- encoding : utf-8 -*-


#Angenommen /^man editiert einen Gegenstand, wo man der Besitzer ist(, der am Lager)?( und in keinem Vertrag vorhanden ist)?$/ do |arg1, arg2|
Given(/^I edit an item that belongs to the current inventory pool( and is in stock)?( and is not part of any contract)?$/) do |in_stock, not_in_contract|
  items = @current_inventory_pool.items.items.where(owner_id: @current_inventory_pool, models: {is_package: false}).order("RAND()")
  items = items.in_stock if in_stock

  @item = if not_in_contract
            items.detect { |i| ContractLine.where(item_id: i.id).empty? }
          else
            items.first
          end

  visit manage_edit_item_path @current_inventory_pool, @item
  expect(has_selector?(".row.emboss")).to be true
end

#Dann /^muss der "(.*?)" unter "(.*?)" ausgewählt werden$/ do |key, section|
Then(/^"(.*?)" must be selected in the "(.*?)" section$/) do |key, section|
  field = find("[data-type='field']", text: key)
  expect(field[:"data-required"]).to eq "true"
end

#Wenn /^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" angegeben werden$/ do |value, key, newkey|
When(/^"(.*?)" is selected for "(.*?)", "(.*?)" must also be supplied$/) do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.find("label,option", match: :first, :text => value).click
  newfield = find("[data-type='field']", text: newkey)
  expect(newfield[:"data-required"]).to eq "true"
end

#Dann /^sind alle Pflichtfelder mit einem Stern gekenzeichnet$/ do
Then(/^all required fields are marked with an asterisk$/) do
  all(".field[data-required='true']", :visible => true).each do |field|
    expect(field.text[/\*/]).not_to be_nil
  end
  all(".field:not([data-required='true'])").each do |field|
    expect(field.text[/\*/]).to eq nil
  end
end

#Wenn /^ein Pflichtfeld nicht ausgefüllt\/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern$/ do
Then(/^I cannot save the item if a required field is empty$/) do
  find(".field[data-required='true'] textarea", match: :first).set("")
  find(".field[data-required='true'] input[type='text']", match: :first).set("")
  find("#item-save").click
  step "I see an error message"
  expect(@item.to_json).to eq @item.reload.to_json
end

# Wenn /^die nicht ausgefüllten\/ausgewählten Pflichtfelder sind rot markiert$/ do
When(/^the required fields are highlighted in red$/) do
  all(".field[data-required='true']", :visible => true).each do |field|
    if field.all("input[type=text]").any? { |input| input.value == 0 } or
        field.all("textarea").any? { |textarea| textarea.value == 0 } or
        (ips = field.all("input[type=radio]"); ips.all? { |input| not input.checked? } if not ips.empty?)
      expect(field[:class][/invalid/]).not_to be_nil
    end
  end
end

# Dann /^sehe ich die Felder in folgender Reihenfolge:$/ do |table|
Then(/^I see form fields in the following order:$/) do |table|
  expected_values = []
  expected_headlines = []
  table.rows.each do |tr|
    expected_headlines << tr[0] if tr[0].match(/^\-.*\-$/)
    expected_values << tr[0].chomp if !tr[0].match(/^\-.*\-$/)
  end
  headlines = find('#flexible-fields').all('h2').map { |hl| "- #{hl.text} -" }.compact
  values = find('#flexible-fields').all("div[data-type='key']").map do |element|
    element.text.gsub(' *','').chomp
  end
  expect(headlines).to eq(expected_headlines)
  expect(values).to eq(expected_values)
end

#Wenn(/^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" ausgewählt werden$/) do |value, key, newkey|
When(/^"(.*?)" is selected for "(.*?)", "(.*?)" must also be selected$/) do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.find("option", match: :first, :text => value).select_option
  newfield = find("[data-type='field']", text: newkey)
  expect(newfield[:"data-required"]).to eq "true"
end

# Dann(/^ist der Gegenstand mit all den angegebenen Informationen gespeichert$/) do
#   find(:select, "retired").first("option").select_option if @table_hashes.detect { |r| r["Feldname"] == "Ausmusterung" } and (@table_hashes.detect { |r| r["Feldname"] == "Ausmusterung" }["Wert"]) == "Ja"
#   step %Q(I search for "%s") %  (@table_hashes.detect { |r| r["Feldname"] == "Inventarcode" }["Wert"])
#   find(".line", :text => @table_hashes.detect { |r| r["Feldname"] == "Modell" }["Wert"], :visible => true)
#   step "I am on this item's edit page"
#   step 'hat der Gegenstand alle zuvor eingetragenen Werte'
# end

#Wenn(/^ich den Lieferanten lösche$/) do
When(/^I delete the supplier$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Supplier")).find("input").set ""
end

#Dann(/^wird der neue Lieferant gelöscht$/) do
Then(/^the new supplier is deleted$/) do
  expect(has_content?(_("List of Inventory"))).to be true
  expect(Supplier.find_by_name(@new_supplier)).not_to be_nil
end

#Dann(/^ist bei dem bearbeiteten Gegenstand keiner Lieferant eingetragen$/) do
Then(/^the item has no supplier$/) do
  expect(has_content?(_("List of Inventory"))).to be true
  expect(@item.reload.supplier).to eq nil
end

#Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes mit gesetztem Lieferanten$/) do
And(/^I navigate to the edit page of an item that has a supplier$/) do
  @item = @current_inventory_pool.items.find { |i| not i.supplier.nil? }
  step "I am on this item's edit page"
end

#Wenn(/^ich den Lieferanten ändere$/) do
When(/^I change the supplier$/) do
  @supplier = Supplier.first
  @new_supplier = @supplier.name # A later step looks for this instead of @supplier, maybe
                            # fix the later step instead?
  fill_in_autocomplete_field _("Supplier"), @supplier.name
end

#Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist und wo man Besitzer ist$/) do
Given(/^I edit an item that belongs to the current inventory pool and is not in stock$/) do
  @item = @current_inventory_pool.own_items.not_in_stock.order("RAND()").first
  @item_before = @item.to_json
  step "I am on this item's edit page"
end

# Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist$/) do
#   @item = @current_inventory_pool.items.not_in_stock.order("RAND()").first
#   @item_before = @item.to_json
#   step "I am on this item's edit page"
# end

#Wenn(/^ich die verantwortliche Abteilung ändere$/) do
When(/^I change the responsible department$/) do
  fill_in_autocomplete_field _("Responsible"), InventoryPool.where("id != ?", @item.inventory_pool.id).order("RAND()").first.name
end

# Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der in einem Vertrag vorhanden ist$/) do
#   @item = @current_inventory_pool.items.items.not_in_stock.order("RAND()").first
#   @item_before = @item.to_json
#   step "I am on this item's edit page"
# end

#Wenn(/^ich das Modell ändere$/) do
When(/^I change the model$/) do
  fill_in_autocomplete_field _("Model"), @current_inventory_pool.models.order("RAND()").detect { |m| m != @item.model }.name
end

#Wenn(/^ich den Gegenstand ausmustere$/) do
When(/^I retire the item$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Retirement")).find("select", match: :first).select _("Yes")
  find(".row.emboss", match: :prefer_exact, text: _("Reason for Retirement")).find("input, textarea", match: :first).set "Retirement reason"
end

Given(/^there is a model without a version$/) do
  @model = Model.find { |m| !m.version }
  expect(@model).not_to be_nil
end

When(/^I assign this model to the item$/) do
  fill_in_autocomplete_field _("Model"), @model.name
end

Then(/^there is only product name in the input field of the model$/) do
  expect(find("input[data-autocomplete_value_target='item[model_id]']").value).to eq @model.product
end
