# -*- encoding : utf-8 -*-

Angenommen /^man editiert einen Gegenstand, wo man der Besitzer ist$/ do
  @ip = @current_user.managed_inventory_pools.first
  @item = @ip.items.where(:owner_id => @ip.id).sample
  visit manage_edit_item_path @ip, @item
end

Dann /^muss der "(.*?)" unter "(.*?)" ausgewählt werden$/ do |key, section|
  field = find("[data-type='field']", text: key)
  field[:"data-required"].should == "true"
end

Wenn /^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" angegeben werden$/ do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.first("label,option", :text => value).click
  newfield = find("[data-type='field']", text: newkey)
  newfield[:"data-required"].should == "true"
end

Dann /^sind alle Pflichtfelder mit einem Stern gekenzeichnet$/ do
  all(".field[data-required='true']", :visible => true).each {|field| field.text[/\*/].should_not be_nil}
  all(".field:not([data-required='true'])").each {|field| field.text[/\*/].should be_nil}
end

Wenn /^ein Pflichtfeld nicht ausgefüllt\/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern$/ do
  first(".field[data-required='true'] textarea").set("")
  first(".field[data-required='true'] input[type='text']").set("")
  find("#item-save").click
  find("#flash .error")
  @item.to_json.should == @item.reload.to_json
end

Wenn /^der Benutzer sieht eine Fehlermeldung$/ do
  first(".notification.error")
end

Wenn /^die nicht ausgefüllten\/ausgewählten Pflichtfelder sind rot markiert$/ do
  all(".field[data-required='true']", :visible => true).each do |field|
    if field.all("input[type=text]").any?{|input| input.value == 0} or 
      field.all("textarea").any?{|textarea| textarea.value == 0} or
      (ips = field.all("input[type=radio]"); ips.all?{|input| not input.checked?} if not ips.empty?)
        field[:class][/invalid/].should_not be_nil
    end
  end
end

Dann /^sehe ich die Felder in folgender Reihenfolge:$/ do |table|
  values = table.raw.map do |x|
    x.first.gsub(/^\-\ |\ \-$/, '')
  end
  (page.text =~ Regexp.new(values.join('.*'), Regexp::MULTILINE)).should_not be_nil
end

Wenn(/^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" ausgewählt werden$/) do |value, key, newkey|
  field = find("[data-type='field']", text: key)
  field.first("option", :text => value).select_option
  newfield = find("[data-type='field']", text: newkey)
  newfield[:"data-required"].should == "true"
end

Angenommen(/^man navigiert zur Gegenstandsbearbeitungsseite$/) do
  @item = @current_inventory_pool.items.first
  visit manage_edit_item_path(@current_inventory_pool, @item)
end

Angenommen(/^man navigiert zur Gegenstandsbearbeitungsseite eines Gegenstandes, der am Lager und in keinem Vertrag vorhanden ist$/) do
  @item = @current_inventory_pool.items.find {|i| i.in_stock? and i.contract_lines.blank?}
  visit manage_edit_item_path(@current_inventory_pool, @item)
  page.should have_selector(".row.emboss")
end

Wenn(/^ich speichern druecke$/) do
  find("button", text: _("Save %s") % _("Item")).click
end

Dann(/^bei dem bearbeiteten Gegestand ist der neue Lieferant eingetragen$/) do
  @item.reload.supplier.name.should == @new_supplier
end

Dann(/^ist der Gegenstand mit all den angegebenen Informationen gespeichert$/) do
  find("[data-retired='true']").click if @table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"} and (@table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"} ["Wert"]) == "Ja"
  find_field('list-search').set (@table_hashes.detect {|r| r["Feldname"] == "Inventarcode"} ["Wert"])
  find(".line", :text => @table_hashes.detect {|r| r["Feldname"] == "Modell"} ["Wert"], :visible => true)
  visit manage_edit_item_path @current_inventory_pool.id, @item.id
  step 'hat der Gegenstand alle zuvor eingetragenen Werte'
  sleep(0.33) # fix lazy request problem
end

Wenn(/^ich den Lieferanten lösche$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Supplier")).find("input").set ""
  page.execute_script %Q{ $("[data-autocomplete_extended_key_target='item[supplier][name]']").trigger('change') }
end

Dann(/^wird der neue Lieferant gelöscht$/) do
  page.should have_content _("List of Inventory")
  Supplier.find_by_name(@new_supplier).should_not be_nil
end

Dann(/^ist bei dem bearbeiteten Gegenstand keiner Lieferant eingetragen$/) do
  page.should have_content _("List of Inventory")
  @item.reload.supplier.should be_nil
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes mit gesetztem Lieferanten$/) do
  @item = @current_inventory_pool.items.find {|i| not i.supplier.nil?}
  visit manage_edit_item_path(@current_inventory_pool, @item)
end

Wenn(/^ich den Lieferanten ändere$/) do
  @supplier = Supplier.first
  fill_in_autocomplete_field _("Supplier"), @supplier.name
end

Dann(/^ist bei dem bearbeiteten Gegestand der geänderte Lieferant eingetragen$/) do
  @item.reload.supplier.should == @supplier
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist und wo man Besitzer ist$/) do
  @item = @current_inventory_pool.own_items.not_in_stock.sample
  @item_before = @item.to_json
  visit manage_edit_item_path(@current_inventory_pool, @item)
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der ausgeliehen ist$/) do
  @item = @current_inventory_pool.items.not_in_stock.sample
  @item_before = @item.to_json
  visit manage_edit_item_path(@current_inventory_pool, @item)
end

Wenn(/^ich die verantwortliche Abteilung ändere$/) do
  fill_in_autocomplete_field _("Responsible"), InventoryPool.where("id != ?", @item.inventory_pool.id).sample.name
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes, der in einem Vertrag vorhanden ist$/) do
  @item = @current_inventory_pool.items.select{|i| not i.contract_lines.blank?}.sample
  @item_before = @item.to_json
  visit manage_edit_item_path(@current_inventory_pool, @item)
end

Wenn(/^ich das Modell ändere$/) do
  fill_in_autocomplete_field _("Model"), @current_inventory_pool.models.select{|m| m != @item.model}.sample.name
end

Wenn(/^ich den Gegenstand ausmustere$/) do
  find(".row.emboss", match: :prefer_exact, text: _("Retirement")).first("select").select _("Yes")
  find(".row.emboss", match: :prefer_exact, text: _("Reason for Retirement")).first("input, textarea").set "Retirement reason"
end

Angenommen(/^there is a model without a version$/) do
  @model = Model.find {|m| !m.version}
  @model.should_not be_nil
end

Wenn(/^I assign this model to the item$/) do
  fill_in_autocomplete_field _("Model"), @model.name
end

Dann(/^there is only product name in the input field of the model$/) do
  find("input[data-autocomplete_value_target='item[model_id]']").value.should == @model.product
end
