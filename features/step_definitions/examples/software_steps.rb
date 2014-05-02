# encoding: utf-8

Dann(/^ist die neue Software erstellt und unter Software auffindbar$/) do
  find("[data-software]").click
  step "die Informationen sind gespeichert"
end

Angenommen(/^ich befinde mich auf der Software\-Erstellungsseite$/) do
  visit manage_new_model_path(inventory_pool_id: @current_inventory_pool.id, type: :software)
end

Dann(/^die mögliche Werte für Betriebssystem sind in der folgenden Reihenfolge:$/) do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

Dann(/^die mögliche Werte für Installation sind in der folgenden Reihenfolge:$/) do |table|
  # table is a Cucumber::Ast::Table
  pending # express the regexp above with the code you wish you had
end

Dann(/^kann ich auf mehreren Zeilen Hinweise und Links anfügen$/) do
  @line_1 = "#{Faker::Lorem.word} #{Faker::Internet.url}"
  @line_2 = Faker::Lorem.sentence
  find(".field", text: _("Technical Details")).find("textarea").set "#{@line_1}\r\n#{@line_2}"
end

Angenommen(/^ich befinde mich auf der Lizenz\-Erstellungsseite$/) do
  visit manage_new_item_path(inventory_pool_id: @current_inventory_pool.id, type: :license)
end

Dann(/^die mögliche Werte für Aktivierungstyp sind in der folgenden Reihenfolge:$/) do |table|
  find(".field", text: _("Activation Type")).all("option").map(&:text).should == table.rows.flatten
end

Dann(/^die mögliche Werte für Lizenzstyp sind in der folgenden Reihenfolge:$/) do |table|
  find(".field", text: _("License Type")).all("option").map(&:text).should == table.rows.flatten
end

Dann(/^die mögliche Werte für Ausleihbar sind in der folgenden Reihenfolge:$/) do |table|
  find(".field", text: _("Borrowable")).all("label").map(&:text).should == table.rows.flatten
end

Dann(/^die Option "Ausleihbar" ist standardmässig auf "Nicht ausleihbar" gesetzt$/) do
  find("label", text: _("Not Borrowable")).find("input[name='item[is_borrowable]']").should be_selected
end

Angenommen(/^es existiert ein Software\-Produkt$/) do
  Software.all.should_not be_empty
end

Wenn(/^ich die Software setze$/) do
  @software = Software.all.sample
  find(".field", text: _("Software")).find("input").set @software.name
  find(".ui-menu a", text: @software.name).click
end

Wenn(/^eine Inventarnummer vergeben wird$/) do
  find("input[name='item[inventory_code]']").value.should_not be_nil
end

Wenn(/^ich eine Seriennummer eingebe$/) do
  @serial_number = Faker::Lorem.characters(8)
  first(".field[data-type='field']", text: _("Serial Number")).find("input").set @serial_number
end

Wenn(/^ich eine Aktivierungsart eingebe$/) do
  within find(".field", text: _("Activation Type")) do
    @activation_type = all("option").map(&:value).sample
    find("option[value='#{@activation_type}']").click
  end
end

Wenn(/^ich eine Lizenzart eingebe$/) do
  within find(".field", text: _("License Type")) do
    @license_type = all("option").map(&:value).sample
    find("option[value='#{@license_type}']").click
  end
end

Wenn(/^ich die den Wert "ausleihbar" setze$/) do
  @is_borrowable = true
  find("label", text: _("OK")).find("input[name='item[is_borrowable]']").click
end

Dann(/^sind die Informationen dieser Software\-Lizenz gespeichert$/) do
  page.has_selector? ".flash.success"
  license = Item.find_by_serial_number(@serial_number)
  license.type.should == "License"
  license.model.should == @software
  license.properties[:activation_type] == @activation_type
  license.properties[:license_type] == @license_type
  license.is_borrowable?.should be_true
end

Wenn(/^ich eine Software editiere$/) do
  visit manage_inventory_path @current_inventory_pool
  @page_to_return = current_path
  find("a", text: _("Software")).click
  @software = Software.all.sample
  @model_id = @software.id
  find(".line[data-type='software'][data-id='#{@software.id}']").find("a", text: _("Edit Software")).click
end

Wenn(/^ich eine bestehende Software\-Lizenz editiere$/) do
  visit manage_inventory_path @current_inventory_pool
  @page_to_return = current_path
  find("a", text: _("Software")).click
  @software = Software.all.select{|s| not s.items.empty?}.sample
  @license = @software.items.sample
  find(".line[data-type='software'][data-id='#{@software.id}']").find("button[data-type='inventory-expander']") .click
  find(".line[data-type='license'][data-id='#{@license.id}']").find("a", text: _("Edit License")).click
end

Wenn(/^ich eine andere Software auswähle$/) do
  @new_software = Software.all.select{|s| s != @software}.sample
  find(".field", text: _("Software")).find("input").set @new_software.name
  find(".ui-menu a", text: @new_software.name).click
end

Wenn(/^ich eine andere Seriennummer eingebe$/) do
  @new_serial_number = Faker::Lorem.characters(8)
  first(".field[data-type='field']", text: _("Serial Number")).find("input").set @new_serial_number
end

Wenn(/^ich einen anderen Aktivierungstyp wähle$/) do
  @new_activation_type = find(".field", text: _("Activation Type")).all("option").map(&:value).select{|v| v != @license.properties[:activation_type]}.sample
  find(".field", text: _("Activation Type")).find("option[value='#{@new_activation_type}']").click
end

Wenn(/^ich einen anderen Lizenztyp wähle$/) do
  @new_license_type = find(".field", text: _("License Type")).all("option").map(&:value).select{|v| v != @license.properties[:license_type]}.sample
  find(".field", text: _("License Type")).find("option[value='#{@new_license_type}']").click
end

Wenn(/^ich den Wert "Ausleihbar" ändere$/) do
  find(".field", text: _("Borrowable")).find("label", text: "OK").find("input").click
end

Dann(/^sind die Informationen dieser Software\-Lizenz erfolgreich aktualisiert worden$/) do
  page.has_selector? ".flash.success"
  license = Item.find_by_serial_number(@new_serial_number)
  license.type.should == "License"
  license.model.should == @new_software
  license.properties[:activation_type] == @new_activation_type
  license.properties[:license_type] == @new_license_type
  license.is_borrowable?.should be_true
end

Wenn(/^ich mich auf der Softwareliste befinde$/) do
  page.has_selector? "Inventarliste"
  find("a", text: _("Software")).click
end
