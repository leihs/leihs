# encoding: utf-8

Dann(/^ist die neue Software erstellt und unter Software auffindbar$/) do
  find("[data-software]").click
  step "die Informationen sind gespeichert"
end

Angenommen(/^ich befinde mich auf der Software\-Erstellungsseite$/) do
  visit manage_new_model_path(inventory_pool_id: @current_inventory_pool.id, type: :software)
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

Dann(/^die mögliche Werte für Lizenztyp sind in der folgenden Reihenfolge:$/) do |table|
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
  Set.new(license.properties[:operating_system]).should == Set.new(@operating_system_values)
  Set.new(license.properties[:installation]).should == Set.new(@installation_values)
  license.is_borrowable?.should be_true
  license.properties[:license_expiration].should == @license_expiration_date.to_s
  license.properties[:maintenance_contract].should == @maintenance_contract
  license.properties[:maintenance_expiration].should == @maintenance_expiration_date.to_s
  license.properties[:reference].should == @reference
  license.properties[:project_number].should == @project_number
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

When(/^I change the options for operating system$/) do
  @new_operating_system_values = []
  within(".field", text: _("Operating System")) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.select(&:checked?).each(&:click)
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @new_operating_system_values << cb.value
    end
  end
end

When(/^I change the options for installation$/) do
  @new_installation_values = []
  within(".field", text: _("Installation")) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.select(&:checked?).each(&:click)
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @new_installation_values << cb.value
    end
  end
end

Dann(/^sind die Informationen dieser Software\-Lizenz erfolgreich aktualisiert worden$/) do
  page.has_selector? ".flash.success"
  license = Item.find_by_serial_number(@new_serial_number)
  license.type.should == "License"
  license.model.should == @new_software
  license.properties[:activation_type] == @new_activation_type
  license.properties[:license_type] == @new_license_type
  Set.new(license.properties[:operating_system]).should == Set.new(@new_operating_system_values)
  Set.new(license.properties[:installation]).should == Set.new(@new_installation_values)
  license.is_borrowable?.should be_true
  license.properties[:license_expiration].should == @new_license_expiration_date.to_s
  license.properties[:maintenance_contract].should == @new_maintenance_contract.to_s
  license.properties[:maintenance_expiration].should == @maintenance_expiration_date.to_s if @new_maintenance_expiration_date
  license.properties[:reference].should == @new_reference
  license.properties[:project_number].should == @project_number if @project_number
end

Wenn(/^ich mich auf der Softwareliste befinde$/) do
  page.has_selector? "Inventarliste"
  find("a", text: _("Software")).click
end

When(/^if I choose none, one or more of the available options for operating system$/) do
  @operating_system_values = []
  within(".field", text: _("Operating System")) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @operating_system_values << cb.value
    end
  end
end

When(/^if I choose none, one or more of the available options for installation$/) do
  @installation_values = []
  within(".field", text: _("Installation")) do
    checkboxes = all("input[type='checkbox']")
    checkboxes.sample(rand(checkboxes.size)).each do |cb|
      cb.click
      @installation_values << cb.value
    end
  end
end

Then(/^one is able to choose for "(.+)" none, one or more of the following options if form of a checkbox:$/) do |arg1, table|
  within(".field", text: _(arg1)) do
    table.rows.flatten.each do |option|
      find("label", text: _(option), match: :prefer_exact).find("input[type='checkbox']")
    end
  end
end

Then(/^for "(.+)" one can select one of the following options with the help of radio button$/) do |arg1, table|
  within(".field", text: _(arg1)) do
    table.rows.flatten.each do |option|
      find("label", text: option).find("input[type='radio']")
    end
  end
end

Then(/^for "(.*?)" one can select a date$/) do |arg1|
  i = find(".field", text: _(arg1)).find("input")
  i.click
  find(".ui-state-default", match: :first).click
  i.value.should_not be_nil
end

Then(/^for maintenance contract the available options are in the following order:$/) do |table|
  find(".field", text: _("Maintenance contract")).all("option").map(&:text).should == table.raw.flatten
end

Then(/^for "(.*?)" one can enter a number$/) do |arg1|
  within(".field", text: _(arg1)) do
    i = find "input[type='text']"
    i.set (n = rand(500).to_s)
    i.value.should == n
  end
end

Then(/^for "(.*?)" one can enter some text$/) do |arg1|
  within(".field", text: _(arg1)) do
    i = find "input[type='text']"
    i.set (t = Faker::Lorem.words(rand 3).join(" "))
    i.value.should == t
  end
end

Then(/^for "(.*?)" one can select a supplier$/) do |arg1|
  i = find(".field", text: _(arg1)).find "input"
  i.click
  supplier = Supplier.all.sample
  find(".ui-menu-item", text: supplier.name).click
  i.value.should == supplier.name
end

Then(/^for "(.*?)" one can select an inventory pool$/) do |arg1|
  i = find(".field", text: _(arg1)).find "input"
  i.click
  ip = InventoryPool.all.sample
  find(".ui-menu-item", text: ip.name).click
  i.value.should == ip.name
end

When(/^I choose a date for license expiration$/) do
  @license_expiration_date = rand(12).months.from_now.to_date
  find(".field", text: _("License expiration")).find("input").set @license_expiration_date.strftime("%d.%m.%Y")
end

When(/^I choose "(.*?)" for maintenance contract$/) do |arg1|
  o = find(".field", text: _("Maintenance contract")).find("option", text: _(arg1))
  o.select_option
  @maintenance_contract = o.value
end

Then(/^I am not able to choose the maintenance expiration date$/) do
  page.has_no_selector? ".field", text: _("Maintenance expiration")
end

When(/^I choose a date for the maintenance expiration$/) do
  @maintenance_expiration_date = rand(12).months.from_now.to_date
  find(".field", text: _("Maintenance expiration")).find("input").set @maintenance_expiration_date.strftime("%d.%m.%Y")
end

When(/^I choose "(.*?)" as reference$/) do |arg1|
  i = find(".field", text: _("Reference")).find("label", text: _(arg1)).find("input")
  i.click
  @reference = i.value
end

Then(/^I have to enter a project number$/) do
  step "ich speichere"
  step "ich sehe eine Fehlermeldung"
  @project_number = Faker::Lorem.characters(10)
  find(".field", text: _("Project Number")).find("input").set @project_number
end

When(/^I change the license expiration date$/) do
  @new_license_expiration_date = rand(12).months.from_now.to_date
  find(".field", text: _("License expiration")).find("input").set @new_license_expiration_date.strftime("%d.%m.%Y")
end

Wenn(/^I change the value for maintenance contract$/) do
  within find(".field", text: _("Maintenance contract")) do
    o = all("option").detect &:selected?
    find("option[value='#{@new_maintenance_contract = !o.value}']").select_option
  end

  if @new_maintenance_contract
    @new_maintenance_expiration_date = rand(12).months.from_now.to_date
    find(".field", text: _("Maintenance expiration")).find("input").set @new_maintenance_expiration_date.strftime("%d.%m.%Y")
  end
end

When(/^I change the value for reference$/) do
  within(".field", text: _("Reference")) do
    radio_buttons = all("input")
    values = radio_buttons.map(&:value)
    current_value = radio_buttons.detect(&:selected?).value
    @new_reference = values.detect {|v| v != current_value}
    find("input[value='#{@new_reference}']").click
  end

  if @new_reference == "investment"
    @new_project_number = Faker::Lorem.characters(10)
    find(".field", text: _("Project Number")).find("input").set @new_project_number
  end
end
