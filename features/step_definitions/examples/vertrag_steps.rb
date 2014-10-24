# -*- encoding : utf-8 -*-

Angenommen /^man öffnet einen Vertrag bei der Aushändigung( mit Software)?$/ do |arg1|
  step "I open a hand over which has multiple unassigned lines and models in stock%s" % (arg1 ? " with software" : nil)


  step 'I select a license line and assign an inventory code' if arg1
  max = [@hand_over.lines.where(item_id: nil, option_id: nil).select {|l| l.available? }.count, 1].max
  rand(1..max).times do
    step 'I select an item line and assign an inventory code'
  end

  step 'I click hand over'
  step 'I see a summary of the things I selected for hand over'
  step 'I click hand over inside the dialog'
  step 'the contract is signed for the selected items'

  new_window = page.driver.browser.window_handles.last
  page.driver.browser.switch_to.window new_window

  @contract_element = find(".contract")
  @contract = @customer.contracts.where(inventory_pool_id: @current_inventory_pool).signed.sort_by(&:updated_at).last
  @contract_lines_to_take_back = @customer.contract_lines.to_take_back.joins(:contract).where(contracts: {inventory_pool_id: @current_inventory_pool})
end

Dann /^möchte ich die folgenden Bereiche sehen:$/ do |table|
  table.hashes.each do |area|
    case area["Bereich"]
       when "Datum"
         within @contract_element.find(".date") do
           expect(has_content?(Date.today.year)).to be true
           expect(has_content?(Date.today.month)).to be true
           expect(has_content?(Date.today.day)).to be true
         end
      when "Titel", "Vertragsnummer"
         expect(@contract_element.find("h1").has_content?(@contract.id)).to be true
       when "Ausleihender"
         @contract_element.find(".customer")
       when "Verleier"
         @contract_element.find(".inventory_pool")
       when "Liste 1"
         # this list is not always there
       when "Liste 2"
         # this list is not always there
       when "Liste der Zwecke"
         expect(@contract_element.find("section.purposes").has_content?(@contract.purpose)).to be true
       when "Zusätzliche Notiz"
         @contract_element.find("section.note")
       when "Hinweis auf AGB"
         @contract_element.find(".terms")
       when "Unterschrift des Ausleihenden"
         @contract_element.find(".terms_and_signature")
       when "Seitennummer"
         # depends on browser settings
       when "Barcode"
         @contract_element.find(".barcode")
     end
   end
end

Dann /^seh ich den Hinweis auf AGB "(.*?)"$/ do |note|
  expect(@contract_element.find(".terms")).not_to be_nil
end

Dann /^beinhalten Liste (\d+) und Liste (\d+) folgende Spalten:$/ do |arg1, arg2, table|
  within @contract_element do
    table.hashes.each do |area|
      case area["Spaltenname"]
        when "Anzahl"
          @contract.lines.each {|line| find("section.list tr", :text=> line.item.inventory_code).find(".quantity", :text=> line.quantity.to_s) }
        when "Inventarcode"
          @contract.lines.each {|line| find("section.list tr", :text=> line.item.inventory_code) }
        when "Modellname"
          @contract.lines.each {|line| find("section.list tr", :text=> line.item.inventory_code).find(".model_name", :text=> line.item.model.name) }
        when "Startdatum"
          @contract.lines.each {|line|
            line_element = find("section.list tr", :text=> line.item.inventory_code)
            within line_element.find(".start_date") do
              expect(has_content? line.start_date.year).to be true
              expect(has_content? line.start_date.month).to be true
              expect(has_content? line.start_date.day).to be true
            end
          }
        when "Enddatum"
          @contract.lines.each {|line|
            line_element = find("section.list tr", :text=> line.item.inventory_code)
            within line_element.find(".end_date") do
              expect(has_content? line.end_date.year).to be true
              expect(has_content? line.end_date.month).to be true
              expect(has_content? line.end_date.day).to be true
            end
          }
        when "Rückgabedatum"
          @contract.lines.each {|line|
            unless line.returned_date.blank?
              line_element = find("section.list tr", :text=> line.item.inventory_code)
              within line_element.find(".returning_date") do
                expect(has_content? line.returned_date.year).to be true
                expect(has_content? line.returned_date.month).to be true
                expect(has_content? line.returned_date.day).to be true
              end
            end
          }
      end
    end
  end
end

Dann /^sehe ich eine Liste Zwecken, getrennt durch Kommas$/ do
  @contract.lines.each {|line| expect(@contract_element.find(".purposes").has_content? line.purpose.to_s).to be true }
end

Dann /^jeder identische Zweck ist maximal einmal aufgelistet$/ do
  purposes = @contract.lines.sort.map{|l| l.purpose.to_s }.uniq.join('; ')
  @contract_element.find(".purposes > p", text: purposes)
end

Dann /^sehe ich das heutige Datum oben rechts$/ do
  within @contract_element.find(".date") do
    expect(has_content? Date.today.month).to be true
    expect(has_content? Date.today.day).to be true
    expect(has_content? Date.today.year).to be true
  end
end

Dann /^sehe ich den Titel im Format "(.*?)"$/ do |format|
  @contract_element.find("h1").text.match Regexp.new(format.gsub("#", "\\d"))
end

Dann /^sehe ich den Barcode oben links$/ do
  @contract_element.find(".barcode")
end

Dann /^sehe ich den Ausleihenden oben links$/ do
  @contract_element.find(".parties .customer")
end

Dann /^sehe ich den Verleiher neben dem Ausleihenden$/ do
  @contract_element.find(".parties .inventory_pool")
end

Dann /^möchte ich im Feld des Ausleihenden die folgenden Bereiche sehen:$/ do |table|
  @customer_element = find(".parties .customer")
  @customer = @contract.user
  table.hashes.each do |area|
    case area["Bereich"]
       when "Vorname"
         expect(@customer_element.has_content?(@customer.firstname)).to be true
       when "Nachname"
         expect(@customer_element.has_content?(@customer.lastname)).to be true
       when "Strasse", "Hausnummer"
         expect(@customer_element.has_content?(@customer.address)).to be true
       when "Länderkürzel", "PLZ"
         expect(@customer_element.has_content?(@customer.zip)).to be true
       when "Stadt"
         expect(@customer_element.has_content?(@customer.city)).to be true
     end
   end
end

Wenn /^es Gegenstände gibt, die zurückgegeben wurden$/ do
  visit manage_take_back_path(@current_inventory_pool, @customer)
  step 'I select all lines of an open contract'
  step 'I click take back'
  step 'I see a summary of the things I selected for take back'
  step 'I click take back inside the dialog'
  visit manage_contracts_path(@current_inventory_pool, status: [:signed, :closed])
  document_window = window_opened_by do
    find(".line .multibutton a", match: :first, text: _("Contract")).click
  end
  page.driver.browser.switch_to.window(document_window.handle)
end

Dann /^sehe ich die Liste (\d+) mit dem Titel "(.*?)"$/ do |arg1, titel|
  find(".contract")

  if titel == "Zurückgegebene Gegenstände"
    find_titel = _("Returned Items")
  elsif titel == "Ausgeliehene Gegenstände"
    find_titel = _("Borrowed Items")
  end

  find(".contract", :text => find_titel)
end

Dann /^diese Liste enthält Gegenstände die ausgeliehen und zurückgegeben wurden$/ do
  all(".modal .contract .returning_date").each do |date|
    expect(date).not_to eq ""
  end
end

Wenn /^es Gegenstände gibt, die noch nicht zurückgegeben wurden$/ do
  @not_returned = @contract.lines.select{|lines| lines.returned_date.nil?}
end

Dann /^diese Liste enthält Gegenstände, die ausgeliehen und noch nicht zurückgegeben wurden$/ do
  @not_returned.each do |line|
    within @contract_element.find(".not_returned_items") do
      expect(has_content? line.model.name).to be true
      expect(has_content? line.item.inventory_code).to be true
    end
  end
end

When(/^die Modelle sind innerhalb ihrer Gruppe alphabetisch sortiert$/) do
  not_returned_lines, returned_lines = @contract.lines.partition {|line| line.returned_date.blank? }

  unless returned_lines.empty?
    names = all(".contract .returned_items tbody .model_name").map{|name| name.text}
    expect(names.empty?).to be false
    expect(names.sort == names).to be true
  end

  unless not_returned_lines.empty?
    names = all(".contract .not_returned_items tbody .model_name").map{|name| name.text}
    expect(names.empty?).to be false
    expect(names.sort == names).to be true
  end
end

Dann(/^wird unter 'Verleiher\/in' der Gerätepark aufgeführt$/) do
  find(".inventory_pool", text: @contract.inventory_pool.name)
end

Angenommen(/^es gibt einen Kunden mit Vertrag wessen Addresse mit "(.*?)" endet$/) do |arg1|
  @user = @current_inventory_pool.users.customers.find {|u| u.contracts.where(status: [:signed, :closed]).exists? and u.read_attribute(:address) =~ /, $/}
  expect(@user).not_to be_nil
end

Wenn(/^ich einen Vertrag dieses Kunden öffne$/) do
  visit manage_contract_path(@current_inventory_pool, @user.contracts.where(status: [:signed, :closed]).sample)
end

Dann(/^wird seine Adresse ohne den abschliessenden "(.*?)" angezeigt$/) do |arg1|
  find(".street", text: @user.address)
end

Wenn(/^in den globalen Einstellungen die Adresse der Instanz konfiguriert ist$/) do
  @address = Setting::CONTRACT_LENDING_PARTY_STRING
  expect(@address).not_to be_nil
end

Dann(/^wird unter dem Verleiher diese Adresse angezeigt$/) do
  all(".inventory_pool span")[1].text == @address
end

Wenn(/^the contract contains a software license$/) do
  @selected_items_with_license = @selected_items.select {|i| i.model.is_a? Software }
  expect(@selected_items_with_license).not_to be_empty
end

Dann(/^I additionally see the following informations$/) do |table|
  table.raw.flatten.each do |s|
    case s
      when "Seriennummer"
        @selected_items_with_license.each do |item|
          find(".contract tbody .model_name", text: item.serial_number)
        end
      else
        raise
    end
  end

end
