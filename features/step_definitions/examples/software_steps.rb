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
  pending # express the regexp above with the code you wish you had
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

Wenn(/^ich das Modell setze$/) do
  @software = Software.all.sample
  find(".field", text: _("Model")).find("input").set @software.name
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
  license.activation_type == @activation_type
  license.license_type == @license_type
  license.is_borrowable?.should be_true
end
