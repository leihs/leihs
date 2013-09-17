# -*- encoding : utf-8 -*-

Angenommen /^man editiert einen Gegenstand, wo man der Besitzer ist$/ do
  @ip = @current_user.managed_inventory_pools
  visit backend_inventory_pool_inventory_path(@ip)
  find("label", text: _("Owned")).click
  wait_until { all(".loading", :visible => true).empty? }
  find(".model.line .toggle .text", :text => /(1|2|3|4|5|6)/).click
  item_line = find(".item.line")
  @item = Item.find_by_inventory_code(item_line.find(".inventory_code").text)
  item_line.find(".actions .button", :text => /(Editieren|Edit)/i).click
end

Dann /^muss der "(.*?)" unter "(.*?)" ausgewählt werden$/ do |key, section|
  section = find("h2", :text => section).find(:xpath, "./..")
  field = section.find("h3", :text => key).find(:xpath, "./..")
  field[:class][/required/].should_not be_nil
end

Wenn /^"(.*?)" bei "(.*?)" ausgewählt ist muss auch "(.*?)" angegeben werden$/ do |value, key, newkey|
  field = find("h3", :text => key).find(:xpath, "./..")
  field.find("label,option", :text => value).click
  newfield = find("h3", :text => newkey).find(:xpath, "./..")
  newfield[:class][/required/].should_not be_nil
end

Dann /^sind alle Pflichtfelder mit einem Stern gekenzeichnet$/ do
  all(".field.required", :visible => true).each {|field| field.text[/\*/].should_not be_nil}
  all(".field:not(.required)").each {|field| field.text[/\*/].should be_nil}
end

Wenn /^ein Pflichtfeld nicht ausgefüllt\/ausgewählt ist, dann lässt sich der Gegenstand nicht speichern$/ do
  find(".field.required textarea").set("")
  find(".field.required input[type='text']").set("")
  find(".content_navigation button[type=submit]").click
  find(".content_navigation button[type=submit]")
  @item.to_json.should == @item.reload.to_json
end

Wenn /^der Benutzer sieht eine Fehlermeldung$/ do
  find(".notification.error")
end

Wenn /^die nicht ausgefüllten\/ausgewählten Pflichtfelder sind rot markiert$/ do
  all(".required.field", :visible => true).each do |field|
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
  field = find("h3", :text => key).find(:xpath, "./..")
  field.find("option", :text => value).select_option
  newfield = find("h3", :text => newkey).find(:xpath, "./..")
  newfield[:class][/required/].should_not be_nil
end

Angenommen(/^man navigiert zur Gegenstandsbearbeitungsseite$/) do
  @item = @current_inventory_pool.items.first
  visit backend_inventory_pool_item_path(@current_inventory_pool, @item)
end

Angenommen(/^man navigiert zur Gegenstandsbearbeitungsseite eines Gegenstandes, der am Lager und in keinem Vertrag vorhanden ist$/) do
  @item = @current_inventory_pool.items.find {|i| i.in_stock? and i.contract_lines.blank?}
  visit backend_inventory_pool_item_path(@current_inventory_pool, @item)
end

Wenn(/^ich speichern druecke$/) do
  find("button", text: _("Save %s") % _("Item")).click
  step "ensure there are no active requests"
end

Dann(/^bei dem bearbeiteten Gegestand ist der neue Lieferant eingetragen$/) do
  @item.reload.supplier.name.should == @new_supplier
end

Dann(/^ist der Gegenstand mit all den angegebenen Informationen gespeichert$/) do
  find("a[data-tab*='retired']").click if (@table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"} ["Wert"]) == "Ja"
  find_field('query').set (@table_hashes.detect {|r| r["Feldname"] == "Inventarcode"} ["Wert"])
  wait_until { all("li.modelname").first.text =~ /#{@table_hashes.detect {|r| r["Feldname"] == "Modell"} ["Wert"]}/ }
  find(".toggle .icon").click
  find(".button", text: 'Gegenstand editieren').click

  wait_until { all("form").count == 2 }
  step 'hat der Gegenstand alle zuvor eingetragenen Werte'
end

Wenn(/^ich den Lieferanten lösche$/) do
  find(".field", text: _("Supplier")).find("input").set ""
end

Dann(/^wird der neue Lieferant gelöscht$/) do
  page.should have_content _("List of Inventory")
  Supplier.find_by_name(@new_supplier).should_not be_nil
end

Dann(/^ist bei dem bearbeiteten Gegenstand keiner Lieferant eingetragen$/) do
  @item.reload.supplier.should be_nil
end

Angenommen(/^man navigiert zur Bearbeitungsseite eines Gegenstandes mit gesetztem Lieferanten$/) do
  @item = @current_inventory_pool.items.find {|i| not i.supplier.nil?}
  visit backend_inventory_pool_item_path(@current_inventory_pool, @item)
end

Wenn(/^ich den Lieferanten ändere$/) do
  @supplier = Supplier.first
  fill_in_autocomplete_field _("Supplier"), @supplier.name
end

Dann(/^ist bei dem bearbeiteten Gegestand der geänderte Lieferant eingetragen$/) do
  @item.reload.supplier.should == @supplier
end