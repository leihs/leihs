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

Wenn(/^eine Inventarnummer vergeben wird$/) do
  find("input[name='item[inventory_code]']").value.should_not be_nil
end

Wenn(/^ich eine Seriennummer eingebe$/) do
  @serial_number = Faker::Lorem.characters(8)
  find(".field[data-type='field']", match: :first, text: _("Serial Number")).find("input").set @serial_number
end

Wenn(/^ich eine Aktivierungsart eingebe$/) do
  within(".field", text: _("Activation Type")) do
    @activation_type = all("option").map(&:value).sample
    find("option[value='#{@activation_type}']").click
  end
end

Wenn(/^ich eine Lizenzart eingebe$/) do
  within(".field", text: _("License Type")) do
    @license_type = all("option").map(&:value).sample
    find("option[value='#{@license_type}']").click
  end
end

Wenn(/^ich die den Wert "ausleihbar" setze$/) do
  @is_borrowable = true
  find("label", text: _("OK")).find("input[name='item[is_borrowable]']").click
end

Dann(/^sind die Informationen dieser Software\-Lizenz gespeichert$/) do
  page.should have_selector "#flash .success"
  license = Item.find_by_serial_number(@serial_number)
  license.type.should == "License"
  license.model.should == @software
  license.properties[:activation_type] == @activation_type
  license.properties[:dongle_id] == @dongle_id
  license.properties[:license_type] == @license_type
  license.properties[:quantity] == @quantity
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
  @software ||= Software.all.sample
  visit manage_inventory_path @current_inventory_pool
  @page_to_return = current_path
  find("a", text: _("Software")).click
  @model_id = @software.id
  find(".line[data-type='software'][data-id='#{@software.id}']").find("a", text: _("Edit Software")).click
end

Wenn(/^ich eine bestehende Software\-Lizenz editiere$/) do
  visit manage_inventory_path @current_inventory_pool
  @page_to_return = current_path
  find("a", text: _("Software"), match: :first).click
  @software = Software.all.select{|s| not s.items.empty?}.sample
  @license = @software.items.sample
  find(".line[data-type='software'][data-id='#{@software.id}']").find("button[data-type='inventory-expander']") .click
  find(".line[data-type='license'][data-id='#{@license.id}']").find("a", text: _("Edit License")).click
end

Wenn(/^ich eine andere Software auswähle$/) do
  @new_software = Software.all.select{|s| s != @software}.sample
  find(".field", text: _("Software"), match: :first).find("input").set @new_software.name
  find(".ui-menu a", text: @new_software.name).click
end

Wenn(/^ich eine andere Seriennummer eingebe$/) do
  @new_serial_number = Faker::Lorem.characters(8)
  find(".field[data-type='field']", match: :first, text: _("Serial Number")).find("input").set @new_serial_number
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
  page.should have_selector "#flash .success"
  license = Item.find_by_serial_number(@new_serial_number)
  license.type.should == "License"
  license.model.should == @new_software
  license.properties[:activation_type] == @new_activation_type
  license.properties[:license_type] == @new_license_type
  license.properties[:quantity] == @quantity
  Set.new(license.properties[:operating_system]).should == Set.new(@new_operating_system_values)
  Set.new(license.properties[:installation]).should == Set.new(@new_installation_values)
  license.is_borrowable?.should be_true
  license.invoice_date.should == (@new_invoice_date.blank? ? nil : @new_invoice_date.to_s)
  license.properties[:license_expiration].should == @new_license_expiration_date.to_s
  license.properties[:maintenance_contract].should == @new_maintenance_contract.to_s
  license.properties[:maintenance_expiration].should == @maintenance_expiration_date.to_s if @new_maintenance_expiration_date
  license.properties[:reference].should == @new_reference
  license.properties[:project_number].should == @project_number if @project_number
end

Wenn(/^ich mich auf der Softwareliste befinde$/) do
  page.should have_content _("List of Inventory")
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
    i = find "input[type='text'],textarea"
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
  page.should_not have_selector ".field", text: _("Maintenance expiration")
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
  within(".field", text: _("Maintenance contract")) do
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

Given(/^there is a software product with the following properties:$/) do |table|
  model_attrs = {}
  @software_product_properties = table.raw.map do |k, v|
    case k
      when "Produktname"
        model_attrs[:product] = v
      when "Hersteller"
        model_attrs[:manufacturer] = v
    end
    v
  end

  @software_product = FactoryGirl.create :software, model_attrs

  table.raw.flatten.each do |property|
    case property
      when "in keinem Vertrag aufgeführt"
        @software_product.contract_lines.should be_empty
      when "keiner Bestellung zugewiesen"
        @software_product.contract_lines.should be_empty
      when "keine Software-Lizenz zugefügt"
        @software_product.items.should be_empty
    end
  end
end

Given(/^there is a software license with the following properties:$/) do |table|
  item_attrs = {owner: @current_inventory_pool}

  lp = table.raw.map do |k, v|
    case k
      when "Inventarnummer"
        item_attrs[:inventory_code] = v
      when "Seriennummer"
        item_attrs[:serial_number] = v
      when "Dongle-ID"
        item_attrs[:properties] ||= {}
        item_attrs[:properties][:activation_type] = "dongle"
        item_attrs[:properties][:dongle_id] = v
    end
    v
  end

  @software_license_properties = @software_product_properties + lp

  @software_license = FactoryGirl.create :license, item_attrs.merge({model: @software_product})
  step "this software license is handed over to somebody"
end

When(/^I search after one of those software product properties$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @software_product_properties.sample
  search_field.native.send_key :return
  sleep(0.33)
end

When(/^I search after one of those software license properties$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @software_license_properties.sample
  search_field.native.send_key :return
  sleep(0.33)
end

Then(/^they appear all matched software products$/) do
  within "#software" do
    find(".line[data-id='#{@software_product.id}']")
  end
end

Then(/^they appear all matched software licenses$/) do
  within "#licenses" do
    find(".line[data-id='#{@software_license.id}']")
  end
end

Then(/^they appear all matched contracts, in which this software product is contained$/) do
  within "#orders" do
    find(".line[data-id='#{@contract_with_software_license.id}']")
  end
end

Given(/^a software product exists$/) do
  @software_product = FactoryGirl.create :software
end

Given(/^a software license exists$/) do
  step "a software product exists"
  step "there exist licenses for this software product"
end

Given(/^this software license is handed over to somebody$/) do
  @contract_with_software_license = FactoryGirl.create :contract, {inventory_pool: @current_inventory_pool, status: :submitted}
  @contract_with_software_license.lines << FactoryGirl.create(:item_line, {contract: @contract_with_software_license, model: @software_product, item: @software_license})
  @contract_with_software_license.lines.reload.should_not be_empty
end

When(/^I search after the name of that person$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @contract_with_software_license.user.name
  search_field.native.send_key :return
  sleep(0.33)
end

Then(/^it appears the contract of this person in the search results$/) do
  step "they appear all matched contracts, in which this software product is contained"
end

Then(/^it appears this person in the search results$/) do
  within "#users" do
    find(".line [data-id='#{@contract_with_software_license.user_id}']")
  end
end

Given(/^there exist licenses for this software product$/) do
  rand(1..3).times do
    @software_product.items << FactoryGirl.create(:license, {owner: @current_inventory_pool, model: @software_product})
  end
  @software_license = @software_product.items.sample
end

When(/^I see these in my search result$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @software_product.name
  search_field.native.send_key :return
  sleep(0.33)
end

Then(/^I can select to list only software products$/) do
  find("nav a.navigation-tab-item", text: _("Software")).click
  within("#software-search-results") do
    find(".line[data-id='#{@software_product.id}']")
  end
end

Then(/^I can select to list only software licenses$/) do
  find("nav a.navigation-tab-item", text: _("Licenses")).click
  within("#licenses-search-results") do
    find(".line[data-id='#{@software_license.id}']")
  end
end

When(/^I delete this software product from the list$/) do
  find("a", text: _("Software")).click
  within("#inventory") do
    within(".line[data-id='#{@software_product.id}']") do
      find(".multibutton .dropdown-toggle").click
      find(".multibutton .red", :text => _("Delete")).click
    end
  end
  find("#flash .success", text: _("%s successfully deleted") % _("Model"))
end

Then(/^the software product is deleted from the list$/) do
  find("a", text: _("Software")).click
  within("#inventory") do
    page.should_not have_selector(".line[data-id='#{@software_product.id}']")
  end
end

Then(/^the software product is deleted$/) do
  lambda {@software_product.reload}.should raise_error(ActiveRecord::RecordNotFound)
end

When(/^I fill in all the required fields for the license$/) do
  step "I fill in the software"
  @inv_code = find(".field", text: _("Inventory Code")).find("input").value
end

When(/^I fill in the software$/) do
  @software = Software.all.sample
  find(".field", text: _("Software")).find("input").set @software.name
  find(".ui-menu a", text: @software.name).click
end

When(/^I fill in the field "(.*?)" with the value "(.*?)"$/) do |field, value|
  @value = value
  find(".field", text: _(field)).find("input").set @value
end

Then(/^"(.*?)" is saved with two decimal digits$/) do |field|
  item = Item.find_by_inventory_code(@inv_code)
  visit manage_edit_item_path(@current_inventory_pool, item)
  find(".field", text: _(field)).find("input").value.should == @value
end

When(/^I edit a license with set dates for maintenance expiration, license expiration and invoice date$/) do
  @license = Item.find {|i| i.invoice_date and i.properties[:maintenance_expiration] and i.properties[:license_expiration]}
  @license.should_not be_nil
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

When(/^I delete the data for the following fields:$/) do |table|
  table.raw.flatten.each {|field| find(".field", text: _(field)).find("input").set ""}
end

Dann(/^the following fields of the license are empty:$/) do |table|
  table.raw.flatten.each {|field| find(".field", text: _(field)).find("input").value.should be_empty }
end

When(/^I edit the same license$/) do
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

When(/^I edit again this software product$/) do
  string = @table_hashes.select {|x| ["Produkt", "Version", "Hersteller"].include? x["Feld"]}.map {|x| x["Wert"]}.join(' ')
  results = Software.search(string)
  results.size.should == 1
  @software = results.first
  step "ich eine Software editiere"
end

Then(/^outside the the text field, they will additionally displayed lines with link only$/) do
  within "#model-form .field", text: _("Software Information") do
    find(".list-of-lines").all(".line").each do |line|
      line.find("a[target='_blank']")
    end
  end
end

Given(/^ich add a new (?:.+) or I change an existing (.+)$/) do |entity|
  klass = case _(entity)
          when "Modell" then Model
          when "Software" then Software
          end
  @model = klass.all.first
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

Then(/^I see the "Software Information"$/) do
  f = find(".field", text: _("Software Information"))
  i = f.find("textarea")
  i.value.should == @license.model.technical_detail.delete("\r")
  f.should have_selector "a"
end

When(/^I edit an existing software license with software information and attachments$/) do
  @license = @current_inventory_pool.items.licenses.find {|i| i.model.technical_detail =~ /http/ and not i.model.attachments.empty? }
  @license.should_not be_nil
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

Then(/^the software information is not editable$/) do
  f = find(".field", text: _("Software Information"))
  f.find("textarea").should be_disabled
end

Then(/^the links of software information open in a new tab upon clicking$/) do
  f = find(".field", text: _("Software Information"))
  f.all("a").each {|link| link.native.attribute("target").should == "_blank"}
end

Then(/^I see the attachments of the software$/) do
  within(".field", text: _("Attachments")) do
    @license.model.attachments.all?{|a| has_selector?("a", text: a.filename)}.should be_true
  end
end

Then(/^I can open the attachments in a new tab$/) do
  f = find(".field", text: _("Attachments"))
  f.all("a").each {|link| link.native.attribute("target").should == "_blank"}
end

When(/^there exists already a manufacturer$/) do
  @manufacturer = Software.manufacturers.sample
end

Then(/^the manufacturer can be selected from the list$/) do
  input_field = find(".field", text: _("Manufacturer")).find("input")
  input_field.click
  find(".ui-menu-item", text: @manufacturer).click
  input_field.value.should == @manufacturer
end

Wenn(/^I set a non existing manufacturer$/) do
  input_field = find(".field", text: _("Manufacturer")).find("input")
  @manufacturer = Faker::Company.name
  while Software.manufacturers.include?(@manufacturer) do
    @manufacturer = Faker::Company.name
  end
  input_field.set @manufacturer
end

Then(/^the new manufacturer can be found in the manufacturer list$/) do
  input_field = find(".field", text: _("Manufacturer")).find("input")
  input_field.click
  find(".ui-menu-item", text: @manufacturer).click
end

Then(/^I choose dongle as activation type$/) do
  within(".field", text: _("Activation Type")) do
    find("option[value='dongle']").click
  end
end

Then(/^I have to provide a dongle id$/) do
  step "ich speichere"
  step "ich sehe eine Fehlermeldung"
  @dongle_id = Faker::Lorem.characters(10)
  find(".field", text: _("Dongle ID")).find("input").set @dongle_id
end

When(/^I choose one of the following license types$/) do |table|
  find(".field", text: _("License Type")).find("option", text: _(table.rows.flatten.sample)).select_option
end

When(/^I fill in a value$/) do
  find(".field", text: _("Quantity")).find("input").set (@quantity = rand(5..500))
end
