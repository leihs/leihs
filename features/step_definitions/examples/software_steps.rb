# encoding: utf-8

Dann(/^ist die neue Software erstellt und unter Software auffindbar$/) do
  find("[data-type='license']").click
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
  expect(find(".field", text: _("Activation Type")).all("option").map(&:text)).to eq table.rows.flatten
end

Dann(/^die mögliche Werte für Lizenztyp sind in der folgenden Reihenfolge:$/) do |table|
  expect(find(".field", text: _("License Type")).all("option").map(&:text)).to eq table.rows.flatten
end

Dann(/^die mögliche Werte für Ausleihbar sind in der folgenden Reihenfolge:$/) do |table|
  expect(find(".field", text: _("Borrowable")).all("label").map(&:text)).to eq table.rows.flatten
end

Dann(/^die Option "Ausleihbar" ist standardmässig auf "Nicht ausleihbar" gesetzt$/) do
  expect(find("label", text: _("Not Borrowable")).find("input[name='item[is_borrowable]']").selected?).to be true
end

Angenommen(/^es existiert ein Software\-Produkt$/) do
  expect(Software.all.empty?).to be false
end

Wenn(/^ein neuer Inventarcode vergeben wird$/) do
  @target_inventory_code = find("input[name='item[inventory_code]']").value
  expect(@target_inventory_code.blank?).to be false
  expect(Item.find_by_inventory_code(@target_inventory_code)).to eq nil
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
  expect(has_selector?("#flash .success")).to be true
  license = Item.find_by_serial_number(@serial_number)
  expect(license.type).to eq "License"
  expect(license.model).to eq @software
  license.properties[:activation_type] == @activation_type
  license.properties[:dongle_id] == @dongle_id
  license.properties[:license_type] == @license_type
  license.properties[:total_quantity] == @total_quantity
  expect(Set.new(license.properties[:operating_system])).to eq Set.new(@operating_system_values)
  expect(Set.new(license.properties[:installation])).to eq Set.new(@installation_values)
  expect(license.is_borrowable?).to be true
  expect(license.properties[:license_expiration]).to eq @license_expiration_date.to_s
  expect(license.properties[:maintenance_contract]).to eq @maintenance_contract
  expect(license.properties[:maintenance_expiration]).to eq @maintenance_expiration_date.to_s
  expect(license.properties[:reference]).to eq @reference
  expect(license.properties[:project_number]).to eq @project_number
  license.properties[:quantity_allocations] == @quantity_allocations
end

Wenn(/^ich eine Software editiere$/) do
  @software ||= Software.all.sample
  step "I open the Inventory"
  @page_to_return = current_path
  find("a", text: _("Software")).click
  find(:select, "retired").first("option").select_option
  @model_id = @software.id
  find(".line[data-type='software'][data-id='#{@software.id}']").find("a", text: _("Edit Software")).click
end

Wenn(/^ich eine bestehende Software\-Lizenz editiere$/) do
  step "I open the Inventory"
  @page_to_return = current_path
  find("a", text: _("Software"), match: :first).click
  @software = Software.all.select{|s| not s.items.empty?}.sample
  @license = @software.items.sample
  find(".line[data-type='software'][data-id='#{@software.id}']").find("button[data-type='inventory-expander']").click
  find(".line[data-type='license'][data-id='#{@license.id}']").find("a", text: _("Edit License")).click
end

Then(/^I can copy an existing software license$/) do
  step "I'am on the software inventory overview"
  within("#inventory") do
    find(".line[data-type='software'] .button[data-type='inventory-expander'] i.arrow.right", match: :first).click
    within(".group-of-lines .line[data-type='license']", match: :first) do
      within(".multibutton") do
        find(".dropdown-toggle").click
        find(".dropdown-item", text: _("Copy License"))
      end
    end
  end
end

Then(/^I can save and copy the existing software license$/) do
  find(".multibutton .dropdown-toggle.green").click
  find("a[id='item-save-and-copy']", text: _("Save and copy"))
end

Wenn(/^ich eine andere Software auswähle$/) do
  @new_software = Software.all.select{|s| s != @software}.sample
  fill_in_autocomplete_field _("Software"), @new_software.name
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
  expect(has_selector?("#flash .success")).to be true
  license = Item.find_by_serial_number(@new_serial_number)
  expect(license.type).to eq "License"
  expect(license.model).to eq @new_software
  license.properties[:activation_type] == @new_activation_type
  license.properties[:license_type] == @new_license_type
  license.properties[:total_quantity] == @new_total_quantity
  expect(Set.new(license.properties[:operating_system])).to eq Set.new(@new_operating_system_values)
  expect(Set.new(license.properties[:installation])).to eq Set.new(@new_installation_values)
  expect(license.is_borrowable?).to be true
  expect(license.invoice_date).to eq (@new_invoice_date.blank? ? nil : @new_invoice_date.to_s)
  expect(license.properties[:license_expiration]).to eq @new_license_expiration_date.to_s
  expect(license.properties[:maintenance_contract]).to eq @new_maintenance_contract.to_s
  expect(license.properties[:maintenance_expiration]).to eq @new_maintenance_expiration_date.to_s if @new_maintenance_expiration_date
  expect(license.properties[:reference]).to eq @new_reference
  expect(license.properties[:project_number]).to eq @project_number if @project_number
  expect(license.note).to eq @note
  license.properties[:dongle_id] == @dongle_id
  license.properties[:quantity_allocations] == @new_quantity_allocations
end

Wenn(/^ich mich auf der Softwareliste befinde$/) do
  expect(has_content?(_("List of Inventory"))).to be true
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
  expect(i.value).not_to be_nil
end

Then(/^for maintenance contract the available options are in the following order:$/) do |table|
  expect(find(".field", text: _("Maintenance contract")).all("option").map(&:text)).to eq table.raw.flatten
end

Then(/^for "(.*?)" one can enter a number$/) do |arg1|
  within(".field", text: _(arg1)) do
    i = find "input[type='text']"
    i.set (n = rand(500).to_s)
    expect(i.value).to eq n
  end
end

Then(/^for "(.*?)" one can enter some text$/) do |arg1|
  within(".field", text: _(arg1)) do
    i = find "input[type='text'],textarea"
    i.set (t = Faker::Lorem.words(rand 3).join(" "))
    expect(i.value).to eq t
  end
end

Then(/^for "(.*?)" one can select a supplier$/) do |arg1|
  i = find(".field", text: _(arg1)).find "input"
  i.click
  supplier = Supplier.all.sample
  find(".ui-menu-item", text: supplier.name).click
  expect(i.value).to eq supplier.name
end

Then(/^for "(.*?)" one can select an inventory pool$/) do |arg1|
  i = find(".field", text: _(arg1)).find "input"
  i.click
  ip = InventoryPool.all.sample
  find(".ui-menu-item", text: ip.name).click
  expect(i.value).to eq ip.name
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
  expect(has_no_selector?(".field", text: _("Maintenance expiration"))).to be true
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
    find("option[value='#{@new_maintenance_contract = !(o.value == "true")}']").select_option
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

Given(/^there is a (.*) with the following properties:$/) do |arg1, table|
  case arg1
    when "model", "software product"
      model_attrs = {}
      @model_properties = table.raw.map do |k, v|
        case k
          when "Name", "Produktname"
            model_attrs[:product] = v
          when "Hersteller"
            model_attrs[:manufacturer] = v
          else
            raise
        end
        v
      end

      @model = case arg1
                 when "model"
                   FactoryGirl.create :model, model_attrs
                 when "software product"
                   FactoryGirl.create :software, model_attrs
               end

    when "item", "software license"
      item_attrs = {owner: @current_inventory_pool}
      item_properties = table.raw.map do |k, v|
        case k
          when "Inventarcode"
            item_attrs[:inventory_code] = v
          when "Seriennummer"
            item_attrs[:serial_number] = v
          when "Dongle-ID"
            item_attrs[:properties] ||= {}
            item_attrs[:properties][:activation_type] = "dongle"
            item_attrs[:properties][:dongle_id] = v
          when "Anzahl-Zuteilung"
            x,y = v.split(" / ")
            item_attrs[:properties][:quantity_allocations] ||= []
            item_attrs[:properties][:quantity_allocations] << [x, y]
            y
          when "Besitzergerätepark", "verantwortlicher Gerätepark"
            ip_key = case k
                       when "Besitzergerätepark"
                         :owner
                       when "verantwortlicher Gerätepark"
                         :inventory_pool
                     end
            item_attrs[ip_key] = case v
                                   when "Mein Gerätepark"
                                     @current_inventory_pool
                                   when "Anderer Gerätepark"
                                     @other_inventory_pool ||= InventoryPool.where.not(id: @current_inventory_pool).sample
                                 end
          else
            raise
        end
      end

      @item_properties = @model_properties + item_properties

      case arg1
        when "item"
          @item = FactoryGirl.create :item, item_attrs.merge({model: @model})
        when "software license"
          @item = FactoryGirl.create :license, item_attrs.merge({model: @model})
          step "this software license is handed over to somebody"
      end

    else
      raise
  end

end

When(/^I search (in inventory )?after one of those (.*)?properties$/) do |arg1, arg2|
  search_field = if arg1
                   find("#inventory-index-view input#list-search")
                 else
                   find("#topbar-search input#search_term")
                 end
  s = case arg2
        when "software product "
          @model_properties.sample
        when "software license ", ""
          @item_properties.sample
      end
  search_field.set s
  search_field.native.send_key :return
end

When(/^I search (in inventory )?after following properties$/) do |arg1, table|
  search_field = if arg1
                   find("#inventory-index-view input#list-search")
                 else
                   find("#topbar-search input#search_term")
                 end
  s = table.raw.flatten.sample
  search_field.set s
  search_field.native.send_key :return
end

Then(/^they appear all matched (.*)$/) do |arg1|
  if page.has_selector? "#search-overview"
    x,y = case arg1
            when "models"
              ["#models", @model]
            when "items"
              ["#items", @item]
            when "software products"
              ["#software", @model]
            when "software licenses"
              ["#licenses", @item]
            when "contracts, in which this software product is contained"
              ["#orders", @contract_with_software_license]
          end
    within "#search-overview" do
      within x do
        find(".line[data-id='#{y.id}']")
      end
    end
  elsif page.has_selector? "#inventory"
    within "#inventory" do
      case arg1
        when "models"
          find(".line[data-id='#{@model.id}'][data-type='model']")
        when "items"
          if @item.parent_id
            find(".group-of-lines .line[data-id='#{@item.parent_id}'][data-type='item'] button[data-type='inventory-expander']").click
            find(".group-of-lines .group-of-lines .line[data-id='#{@item.id}'][data-type='item']")
          else
            find(".line[data-id='#{@item.model_id}'][data-type='model'] button[data-type='inventory-expander']").click
            find(".group-of-lines .line[data-id='#{@item.id}'][data-type='item']")
          end
        when "package models"
          find(".line[data-id='#{@package_item.model.id}'][data-type='model'][data-is_package='true']")
        when "package items"
          find(".line[data-id='#{@package_item.model_id}'][data-type='model'][data-is_package='true'] button[data-type='inventory-expander']").click
          find(".group-of-lines .line[data-id='#{@package_item.id}'][data-type='item']")
      end
    end
  else
    raise
  end
end

Given(/^a software product exists$/) do
  @model = FactoryGirl.create :software
end

Given(/^a software license exists$/) do
  step "a software product exists"
  step "there exist licenses for this software product"
end

Given(/^this software license is handed over to somebody$/) do
  @contract_with_software_license = FactoryGirl.create :contract, {inventory_pool: @current_inventory_pool, status: :submitted}
  @contract_with_software_license.lines << FactoryGirl.create(:item_line, {contract: @contract_with_software_license, model: @model, item: @item})
  expect(@contract_with_software_license.lines.reload.empty?).to be false
end

When(/^I search after the name of that person$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @contract_with_software_license.user.name
  search_field.native.send_key :return
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
    @model.items << FactoryGirl.create(:license, {owner: @current_inventory_pool, model: @model})
  end
  @item = @model.items.sample
end

When(/^I see these in my search result$/) do
  search_field = find("#topbar-search input#search_term")
  search_field.set @model.name
  search_field.native.send_key :return
end

Then(/^I can select to list only software products$/) do
  find("nav a.navigation-tab-item", text: _("Software")).click
  within("#software-search-results") do
    find(".line[data-id='#{@model.id}']")
  end
end

Then(/^I can select to list only software licenses$/) do
  find("nav a.navigation-tab-item", text: _("Licenses")).click
  within("#licenses-search-results") do
    find(".line[data-id='#{@item.id}']")
  end
end

When(/^I delete this software product from the list$/) do
  find("a", text: _("Software")).click
  within("#inventory") do
    within(".line[data-id='#{@model.id}']") do
      within(".multibutton") do
        find(".dropdown-toggle").click
        find(".red", :text => _("Delete")).click
      end
    end
  end
  find("#flash .success", text: _("%s successfully deleted") % _("Model"))
end

Then(/^the software product is deleted from the list$/) do
  find("a", text: _("Software")).click
  within("#inventory") do
    expect(has_no_selector?(".line[data-id='#{@model.id}']")).to be true
  end
end

Then(/^the software product is deleted$/) do
  expect { @model.reload }.to raise_error(ActiveRecord::RecordNotFound)
end

When(/^I fill in all the required fields for the license$/) do
  step "I fill in the software"
  @inv_code = find(".field", text: _("Inventory Code")).find("input").value
end

When(/^I fill in the software$/) do
  @software = Software.all.sample
  fill_in_autocomplete_field _("Software"), @software.name
end

When(/^I fill in the field "(.*?)" with the value "(.*?)"$/) do |field, value|
  find(".field", text: _(field)).find("input").set value
end

Then(/^"(.*?)" is saved as "(.*?)"$/) do |field, format|
  item = Item.find_by_inventory_code(@inv_code)
  visit manage_edit_item_path(@current_inventory_pool, item)
  expect(find(".field", text: _(field)).find("input").value).to eq format
end

When(/^I edit a license with set dates for maintenance expiration, license expiration and invoice date$/) do
  @license = @current_inventory_pool.items.licenses.find {|i| i.invoice_date and
                                                              i.properties[:maintenance_contract] == "true" and
                                                              i.properties[:maintenance_expiration] and
                                                              i.properties[:license_expiration] }
  expect(@license).not_to be_nil
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

When(/^I delete the data for the following fields:$/) do |table|
  table.raw.flatten.each {|field| find(".field", text: _(field)).find("input").set ""}
end

Dann(/^the following fields of the license are empty:$/) do |table|
  table.raw.flatten.each do |field|
    expect(find(".field", text: _(field)).find("input").value.empty?).to be true
  end
end

When(/^I edit the same license$/) do
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

When(/^I edit again this software product$/) do
  string = @table_hashes.select {|x| ["Produkt", "Version", "Hersteller"].include? x["Feld"]}.map {|x| x["Wert"]}.join(' ')
  results = Software.search(string)
  expect(results.size).to eq 1
  @software = results.first
  step "ich eine Software editiere"
end

Then(/^outside the the text field, they will additionally displayed lines with link only$/) do
  within "#form .field", text: _("Software Information") do
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
  expect(i.value).to eq @license.model.technical_detail.delete("\r")
  expect(f.has_selector? "a").to be true
end

When(/^I edit an existing software license with software information, quantity allocations and attachments$/) do
  @license = @current_inventory_pool.items.licenses.find {|i| i.model.technical_detail =~ /http/ and not i.model.attachments.empty? and i.properties[:quantity_allocations].size >= 2 }
  expect(@license).not_to be_nil
  visit manage_edit_item_path(@current_inventory_pool, @license)
end

Then(/^the software information is not editable$/) do
  f = find(".field", text: _("Software Information"))
  expect(f.find("textarea").disabled?).to be true
end

Then(/^the links of software information open in a new tab upon clicking$/) do
  f = find(".field", text: _("Software Information"))
  f.all("a").each do |link|
    expect(link.native.attribute("target")).to eq "_blank"
  end
end

Then(/^I see the attachments of the software$/) do
  within(".field", text: _("Attachments")) do
    expect(@license.model.attachments.all?{|a| has_selector?("a", text: a.filename)}).to be true
  end
end

Then(/^I can open the attachments in a new tab$/) do
  f = find(".field", text: _("Attachments"))
  f.all("a").each do |link|
    expect(link.native.attribute("target")).to eq "_blank"
  end
end

When(/^there exists already a manufacturer$/) do
  @manufacturer = Software.manufacturers.sample
end

Then(/^the manufacturer can be selected from the list$/) do
  input_field = find(".field", text: _("Manufacturer")).find("input")
  input_field.click
  find(".ui-menu-item", text: @manufacturer).click
  expect(input_field.value).to eq @manufacturer
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
  find(".field", text: _("Quantity")).find("input").set (@total_quantity = rand(5..500))
end

Given(/^a software product with more than (\d+) text rows in field "(.*?)" exists$/) do |arg1, arg2|
  @model = case arg2
             when "Software Informationen"
               r = @current_inventory_pool.models.where(type: "Software").detect {|m| m.technical_detail.to_s.split("\r\n").size > arg1.to_i}
               r ||= begin
                 td = []
                 (arg1.to_i + rand(1..10)).times { td << Faker::Lorem.paragraph }
                 m = @current_inventory_pool.models.sample
                 m.update_attributes(technical_detail: td.join("\r\n"))
                 m
               end
             else
               raise
           end
end

When(/^I edit this software$/) do
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

When(/^I click in the field "(.*?)"$/) do |arg1|
  case arg1
    when "Software Informationen"
      el = find("textarea[name='model[technical_detail]']")
      @original_size = el.native.css_value('height')
      el.click
    else
      raise
  end
end

When(/^this field grows up till showing the complete text$/) do
  expect(find("textarea[name='model[technical_detail]']").native.css_value('height').to_i).to be > @original_size.to_i
end

When(/^I release the focus from this field$/) do
  find("body").click # blur all possible focused autocomplete inputs
end

Then(/^this field shrinks back to the original size$/) do
  expect(find("textarea[name='model[technical_detail]']").native.css_value('height').to_i).to eq @original_size.to_i
end

When(/^I change the value of the note$/) do
  find(".field", text: _("Note")).find("textarea").set (@note = Faker::Lorem.sentence)
end

When(/^I change the value of dongle id$/) do
  dongle_field = first(".field", text: _("Dongle ID"))
  unless dongle_field
    step %Q(I choose dongle as activation type)
    dongle_field = first(".field", text: _("Dongle ID"))
  end
  dongle_field.find("input").set (@dongle_id = Faker::Lorem.characters(8))
end

When(/^I change the value of total quantity$/) do
  find(".field", text: _("Total quantity")).find("input").set (@new_total_quantity = rand(10..100))
end

When(/^I change the quantity allocations$/) do
  @new_quantity_allocations = @license.properties[:quantity_allocations]
  within find(".field", text: _("Quantity allocations")) do
    first("[data-remove]").click
    @new_quantity_allocations.shift
    all("[data-quantity-allocation]").last.set (q = rand(1..50))
    @new_quantity_allocations.last[:quantity] = q
    first("#add-inline-entry").click
    new_inline_entry = first(".list-of-lines .row")
    new_inline_entry.first("[data-quantity-allocation]").set (q = rand(1..50))
    new_inline_entry.first("[data-room-allocation]").set (r = Faker::Lorem.word)
    @new_quantity_allocations.unshift({room: r, quantity: q})
  end
end

When(/^I fill in the value of total quantity$/) do
  find(".field", text: _("Total quantity")).find("input").set (@total_quantity = rand(10..100))
end

When(/^I add the quantity allocations$/) do
  @quantity_allocations = []
  within find(".field", text: _("Quantity allocations")) do
    rand(2..5).times do
      first("#add-inline-entry").click
      new_inline_entry = first(".list-of-lines .row")
      new_inline_entry.first("[data-quantity-allocation]").set (q = rand(1..50))
      new_inline_entry.first("[data-room-allocation]").set (r = Faker::Lorem.word)
      @quantity_allocations.unshift({room: r, quantity: q})
    end
  end
end

When(/^I fill in total quantity with value "(.*?)"$/) do |arg1|
  find(".field", text: _("Total quantity")).find("input").set (@total_quantity = arg1.to_i)
end

Then(/^I see the remaining number of licenses shown as follows "(.*?)"$/) do |arg1|
  within find(".field", text: _("Quantity allocations")) do
    find("#remaining-total-quantity", text: arg1)
  end
end

Then(/^I add the following quantity allocations:$/) do |table|
  within find(".field", text: _("Quantity allocations")) do
    table.rows.each do |row|
      first("#add-inline-entry").click
      new_inline_entry = first(".list-of-lines .row")
      new_inline_entry.first("[data-quantity-allocation]").set row.first
      new_inline_entry.first("[data-room-allocation]").set row.second
    end
  end
end

When(/^I delete the following quantity allocations:$/) do |table|
  within find(".field", text: _("Quantity allocations")) do
    inline_entries = all("[data-type='inline-entry']")
    table.rows.each do |row|
      inline_entry = inline_entries.detect {|ie| ie.find("[data-room-allocation]").value == row.second}
      inline_entry.find("[data-remove]").click
    end
  end
end

When(/^I copy an existing software license$/) do
  step "I'am on the software inventory overview"
  within("#inventory") do
    find(".line[data-id='#{@item.model_id}'][data-type='software'] button[data-type='inventory-expander']").click
    within(".group-of-lines .line[data-id='#{@item.id}'][data-type='license']") do
      within(".multibutton") do
        find(".dropdown-toggle").click
        find(".dropdown-item", text: _("Copy License")).click
      end
    end
  end
end

Then(/^it opens the edit view of the new software license$/) do
  expect(manage_copy_item_path(@current_inventory_pool, @item)).to eq current_path
end

Then(/^the (.*) is labeled as "(.*?)"$/) do |arg1, arg2|
  case arg1
    when "title"
      find("h1.headline-l", text: arg2)
    when "save button"
      find("button.green", text: arg2)
    else
      raise
  end
end

Dann(/^the new software license is created$/) do
  @target_item = @current_inventory_pool.items.find_by_inventory_code(@target_inventory_code)
  expect(@target_item).not_to be_nil
end

Dann(/^the following fields were copied from the original software license$/) do |table|
  table.rows.flatten.each do |field|
    case field
      when "Software"
        expect(@target_item.model_id).to eq @item.model_id
      when "Bezug"
        expect(@target_item.properties[:reference]).to eq @item.properties[:reference]
      when "Besitzer"
        expect(@target_item.owner_id).to eq @item.owner_id
      when "Verantwortliche Abteilung"
        expect(@target_item.inventory_pool_id).to eq @item.inventory_pool_id
      when "Rechnungsdatum"
        expect(@target_item.invoice_date).to eq @item.invoice_date
      when "Anschaffungswert"
        expect(@target_item.price).to eq @item.price
      when "Lieferant"
        expect(@target_item.supplier_id).to eq @item.supplier_id
      when "Beschafft durch"
        expect(@target_item.properties[:procured_by]).to eq @item.properties[:procured_by]
      when "Notiz"
        expect(@target_item.note).to eq @item.note
      when "Aktivierungstyp"
        expect(@target_item.properties[:activation_type]).to eq @item.properties[:activation_type]
      when "Lizenztyp"
        expect(@target_item.properties[:license_type]).to eq @item.properties[:license_type]
      when "Gesamtanzahl"
        expect(@target_item.properties[:quantity]).to eq @item.properties[:quantity]
      when "Betriebssystem"
        expect(@target_item.properties[:operating_system]).to eq @item.properties[:operating_system]
      when "Installation"
        expect(@target_item.properties[:installation]).to eq @item.properties[:installation]
      when "Lizenzablaufdatum"
        expect(@target_item.properties[:license_expiration]).to eq @item.properties[:license_expiration]
      when "Maintenance-Vertrag"
        expect(@target_item.properties[:maintenance_contract]).to eq @item.properties[:maintenance_contract]
      when "Maintenance-Ablaufdatum"
        expect(@target_item.properties[:maintenance_expiration]).to eq @item.properties[:maintenance_expiration]
      when "Währung"
        expect(@target_item.properties[:maintenance_currency]).to eq @item.properties[:maintenance_currency]
      when "Preis"
        expect(@target_item.properties[:maintenance_price]).to eq @item.properties[:maintenance_price]
      else
        raise
    end

  end
end
