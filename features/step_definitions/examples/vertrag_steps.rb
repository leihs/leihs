# -*- encoding : utf-8 -*-

#Angenommen /^man öffnet einen Vertrag bei der Aushändigung( mit Software)?$/ do |arg1|
Given /^I open a contract during hand over( that contains software)?$/ do |arg1|
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
end

#Dann /^möchte ich die folgenden Bereiche sehen:$/ do |table|
Then /^I want to see the following areas:$/ do |table|
  within @contract_element do
    table.hashes.each do |area|
      case area["Area"]
        when "Date"
          within find(".date") do
            expect(has_content?(Date.today.year)).to be true
            expect(has_content?(Date.today.month)).to be true
            expect(has_content?(Date.today.day)).to be true
          end
        when "Title", "Contract number"
          expect(find("h1").has_content?(@contract.id)).to be true
        when "Borrower"
          find(".customer")
        when "Lender"
          find(".inventory_pool")
        when "List 1"
          # this list is not always there
        when "List 2"
          # this list is not always there
        when "List of purposes"
          expect(find("section.purposes").has_content?(@contract.purpose)).to be true
        when "Additional notes"
          find("section.note")
        when "Terms"
          find(".terms")
        when "Borrower's signature"
          find(".terms_and_signature")
        when "Page number"
          # depends on browser settings
        when "Barcode"
          find(".barcode")
      end
    end
  end
end

#Dann /^seh ich den Hinweis auf AGB "(.*?)"$/ do |note|
Then /^I see a note mentioning the terms and conditions$/ do
  expect(@contract_element.find(".terms")).not_to be_nil
end

#Dann /^beinhalten Liste (\d+) und Liste (\d+) folgende Spalten:$/ do |arg1, arg2, table|
Then /^list (\d+) and list (\d+) contain the following columns:$/ do |arg1, arg2, table|
  within @contract_element do
    table.hashes.each do |area|
      case area["Column name"]
        when "Quantity"
          @contract.lines.each {|line|
            within("section.list tr", :text=> line.item.inventory_code) do
              find(".quantity", :text=> line.quantity.to_s)
            end
          }
        when "Inventory code"
          @contract.lines.each {|line| find("section.list tr", :text=> line.item.inventory_code) }
        when "Model name"
          @contract.lines.each {|line|
            within("section.list tr", :text=> line.item.inventory_code) do
              find(".model_name", :text=> line.item.model.name)
            end
          }
        when "Start date"
          @contract.lines.each {|line|
            line_element = find("section.list tr", :text=> line.item.inventory_code)
            within line_element.find(".start_date") do
              expect(has_content? line.start_date.year).to be true
              expect(has_content? line.start_date.month).to be true
              expect(has_content? line.start_date.day).to be true
            end
          }
        when "End date"
          @contract.lines.each {|line|
            line_element = find("section.list tr", :text=> line.item.inventory_code)
            within line_element.find(".end_date") do
              expect(has_content? line.end_date.year).to be true
              expect(has_content? line.end_date.month).to be true
              expect(has_content? line.end_date.day).to be true
            end
          }
        when "Return date"
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

#Dann /^sehe ich eine Liste Zwecken, getrennt durch Kommas$/ do
Then /^I see a comma-separated list of purposes$/ do
  @contract.lines.each {|line| expect(@contract_element.find(".purposes").has_content? line.purpose.to_s).to be true }
end

#Dann /^jeder identische Zweck ist maximal einmal aufgelistet$/ do
Then /^each unique purpose is listed only once$/ do
  purposes = @contract.lines.sort.map{|l| l.purpose.to_s }.uniq.join('; ')
  @contract_element.find(".purposes > p", text: purposes)
end

#Dann /^sehe ich das heutige Datum oben rechts$/ do
Then /^I see today's date in the top right corner$/ do
  within @contract_element.find(".date") do
    expect(has_content? Date.today.month).to be true
    expect(has_content? Date.today.day).to be true
    expect(has_content? Date.today.year).to be true
  end
end

#Dann /^sehe ich den Titel im Format "(.*?)"$/ do |format|
Then /^I see a title in the format "(.*?)"$/ do |format|
  @contract_element.find("h1").text.match Regexp.new(format.gsub("#", "\\d"))
end

#Dann /^sehe ich den Barcode oben links$/ do
Then /^I see the barcode in the top left$/ do
  @contract_element.find(".barcode")
end

#Dann /^sehe ich den Ausleihenden oben links$/ do
Then /^I see the borrower in the top left corner$/ do
  @contract_element.find(".parties .customer")
end

#Dann /^sehe ich den Verleiher neben dem Ausleihenden$/ do
Then /^the lender is shown next to the borrower$/ do
  @contract_element.find(".parties .inventory_pool")
end

#Dann /^möchte ich im Feld des Ausleihenden die folgenden Bereiche sehen:$/ do |table|
Then /^the following user information is included on the contract:$/ do |table|
  @customer_element = find(".parties .customer")
  @customer = @contract.user
  table.hashes.each do |area|
    case area["Area"]
       when "First name"
         expect(@customer_element.has_content?(@customer.firstname)).to be true
       when "Last name"
         expect(@customer_element.has_content?(@customer.lastname)).to be true
       when "Street", "Street Number"
         expect(@customer_element.has_content?(@customer.address)).to be true
       when "Country code", "postal code"
         expect(@customer_element.has_content?(@customer.zip)).to be true
       when "City"
         expect(@customer_element.has_content?(@customer.city)).to be true
     end
   end
end

#Wenn /^es Gegenstände gibt, die zurückgegeben wurden$/ do
When /^there are returned items$/ do
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

#Dann /^sehe ich die Liste (\d+) mit dem Titel "(.*?)"$/ do |arg1, titel|
Then /^I see list (\d+) with the title "(.*?)"$/ do |arg1, titel|
  find(".contract")

  if titel == "Returned Items"
    find_titel = _("Returned Items")
  elsif titel == "Borrowed Items"
    find_titel = _("Borrowed Items")
  end

  find(".contract", :text => find_titel)
end

#Dann /^diese Liste enthält Gegenstände die ausgeliehen und zurückgegeben wurden$/ do
Then /^this list contains borrowed and returned items$/ do
  all(".modal .contract .returning_date").each do |date|
    expect(date).not_to eq ""
  end
end

#Wenn /^es Gegenstände gibt, die noch nicht zurückgegeben wurden$/ do
When /^there are unreturned items$/ do
  @not_returned = @contract.lines.select{|lines| lines.returned_date.nil?}
end

#Dann /^diese Liste enthält Gegenstände, die ausgeliehen und noch nicht zurückgegeben wurden$/ do
Then /^this list contains items that were borrowed but not yet returned$/ do
  @not_returned.each do |line|
    within @contract_element.find(".not_returned_items") do
      expect(has_content? line.model.name).to be true
      expect(has_content? line.item.inventory_code).to be true
    end
  end
end

#When(/^die Modelle sind innerhalb ihrer Gruppe alphabetisch sortiert$/) do
Then(/^the models are sorted alphabetically within their group$/) do
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

#Dann(/^wird unter 'Verleiher\/in' der Gerätepark aufgeführt$/) do
Then(/^the inventory pool is listed as lender$/) do
  find(".inventory_pool", text: @contract.inventory_pool.name)
end

#Angenommen(/^es gibt einen Kunden mit Vertrag wessen Addresse mit "(.*?)" endet$/) do |arg1|
Given(/^there is a contract for a user whose address ends with "(.*?)"$/) do |arg1|
  @user = @current_inventory_pool.users.customers.find {|u| u.reservations_bundles.signed_or_closed.exists? and u.read_attribute(:address) =~ /, $/}
  expect(@user).not_to be_nil
end

#Wenn(/^ich einen Vertrag dieses Kunden öffne$/) do
When(/^I open this user's contract$/) do
  visit manage_contract_path(@current_inventory_pool, @user.reservations_bundles.signed_or_closed.order("RAND()").first)
end

#Dann(/^wird seine Adresse ohne den abschliessenden "(.*?)" angezeigt$/) do |arg1|
Then(/^their address is shown without the  "(.*?)"$/) do |arg1|
  find(".street", text: @user.address)
end

#Wenn(/^in den globalen Einstellungen die Adresse der Instanz konfiguriert ist$/) do
When(/^the instance's address is configured in the global settings$/) do
  @address = Setting::CONTRACT_LENDING_PARTY_STRING
  expect(@address).not_to be_nil
end

#Dann(/^wird unter dem Verleiher diese Adresse angezeigt$/) do
Then(/^the lender address is shown underneath the lender$/) do
  all(".inventory_pool span")[1].text == @address
end

When(/^the contract contains a software license$/) do
  @selected_items_with_license = @selected_items.select {|i| i.model.is_a? Software }
  expect(@selected_items_with_license).not_to be_empty
end

Then(/^I additionally see the following information$/) do |table|
  table.raw.flatten.each do |s|
    case s
      when "Serial number"
        @selected_items_with_license.each do |item|
          find(".contract tbody .model_name", text: item.serial_number)
        end
      else
        raise
    end
  end

end
