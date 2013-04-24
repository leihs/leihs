# -*- encoding : utf-8 -*-

Angenommen /^man öffnet einen Vertrag$/ do
  step %Q{I open a hand over}
  step %Q{I select an item line and assign an inventory code}
  step %Q{I select an item line and assign an inventory code}
  step %Q{I select an item line and assign an inventory code}
  step %Q{I click hand over}
  step %Q{I see a summary of the things I selected for hand over}
  step %Q{I click hand over inside the dialog}
  step %Q{the contract is signed for the selected items}
  @contract_element = find("#print section.contract")
  @contract = @customer.contracts.signed.sort_by(&:updated_at).last
end

Dann /^möchte ich die folgenden Bereiche sehen:$/ do |table|
  table.hashes.each do |area|
    case area["Bereich"]
       when "Datum"
         @contract_element.find(".date").should have_content Date.today.year
         @contract_element.find(".date").should have_content Date.today.month
         @contract_element.find(".date").should have_content Date.today.day
       when "Titel"
         @contract_element.find("h1").should have_content @contract.id
       when "Ausleihender"
         @contract_element.find(".customer")
       when "Verleier"
         @contract_element.find(".inventory_pool")
       when "Liste 1"
         # this list is not always there
       when "Liste 2"
         # this list is not always there
       when "Liste der Zwecke"
         @contract_element.find("section.purposes").should have_content @contract.purpose
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
       when "Vertragsnummer"
         @contract_element.find("h1").should have_content @contract.id
     end
   end
end

Dann /^seh ich den Hinweis auf AGB "(.*?)"$/ do |note|
  @contract_element.find(".terms").should_not be_nil
end

Dann /^beinhalten Liste (\d+) und Liste (\d+) folgende Spalten:$/ do |arg1, arg2, table|
  @list = @contract_element.find("section.list")
  
  table.hashes.each do |area|
    case area["Spaltenname"]
      when "Anzahl"
        @contract.lines.each {|line| @list.find("tr", :text=> line.item.inventory_code).find(".quantity", :text=> line.quantity.to_s) } 
      when "Inventarcode"
        @contract.lines.each {|line| @list.find("tr", :text=> line.item.inventory_code) } 
      when "Modellname"
        @contract.lines.each {|line| @list.find("tr", :text=> line.item.inventory_code).find(".model_name", :text=> line.item.model.name) } 
      when "Startdatum"
        @contract.lines.each {|line| 
          line_element = @list.find("tr", :text=> line.item.inventory_code)
          line_element.find(".start_date").should have_content line.start_date.year 
          line_element.find(".start_date").should have_content line.start_date.month
          line_element.find(".start_date").should have_content line.start_date.day
        } 
      when "Enddatum"
        @contract.lines.each {|line| 
          line_element = @list.find("tr", :text=> line.item.inventory_code)
          line_element.find(".end_date").should have_content line.end_date.year 
          line_element.find(".end_date").should have_content line.end_date.month
          line_element.find(".end_date").should have_content line.end_date.day
        }
      when "Rückgabedatum"
        @contract.lines.each {|line|
          unless line.returned_date.blank? 
            line_element = @list.find("tr", :text=> line.item.inventory_code)
            line_element.find(".returning_date").should have_content line.returned_date.year
            line_element.find(".returning_date").should have_content line.returned_date.month
            line_element.find(".returning_date").should have_content line.returned_date.day
          end
        }
    end
  end
end

Dann /^sehe ich eine Liste Zwecken, getrennt durch Kommas$/ do
  @contract.lines.each {|line| @contract_element.find(".purposes").should have_content line.purpose.to_s }
end

Dann /^jeder identische Zweck ist maximal einmal aufgelistet$/ do
  purposes = @contract.lines.map{|l| l.purpose.to_s }.uniq.join('; ')
  @contract_element.find(".purposes > p").text.should == purposes
end

Dann /^sehe ich das heutige Datum oben rechts$/ do
  @contract_element.find(".date").should have_content Date.today.year
  @contract_element.find(".date").should have_content Date.today.month
  @contract_element.find(".date").should have_content Date.today.day
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
  @customer_element = @contract_element.find(".parties .customer")
  @customer = @contract.user
  table.hashes.each do |area|
    case area["Bereich"]
       when "Vorname"
         @customer_element.should have_content @customer.firstname
       when "Nachname"
         @customer_element.should have_content @customer.lastname
       when "Strasse"
         @customer_element.should have_content @customer.address
       when "Hausnummer"
         @customer_element.should have_content @customer.address
       when "Länderkürzel"
         @customer_element.should have_content @customer.zip
       when "PLZ"
         @customer_element.should have_content @customer.zip
       when "Stadt"
         @customer_element.should have_content @customer.city
     end
   end
end

Wenn /^es Gegenstände gibt, die zurückgegeben wurden$/ do
  visit backend_inventory_pool_user_take_back_path(@contract.inventory_pool, @customer)
  steps %Q{
    And I select all lines of an open contract
    And I click take back
   Then I see a summary of the things I selected for take back
   When I click take back inside the dialog
  }
  visit backend_inventory_pool_contracts_path(@contract.inventory_pool)
  find(".button", :text => /(Contract|Vertrag)/).click
end

Dann /^sehe ich die Liste (\d+) mit dem Titel "(.*?)"$/ do |arg1, titel|
  wait_until{ find(".dialog .contract") }

  if titel == "Zurückgegebene Gegenstände"
    find_titel = /(Returned Items|Zurückgegebene Gegenstände)/
  elsif titel == "Ausgeliehene Gegenstände"
    find_titel = /(Borrowed Items|Geliehene Gegenstände)/
  end

  find(".dialog .contract", :text => find_titel)
end

Dann /^diese Liste enthält Gegenstände die ausgeliehen und zurückgegeben wurden$/ do
  all(".dialog .contract .returning_date").each do |date|
    date.should_not == ""
  end
end

Wenn /^es Gegenstände gibt, die noch nicht zurückgegeben wurden$/ do
  @not_returned = @contract.lines.select{|lines| lines.returned_date.nil?}
end

Dann /^diese Liste enthält Gegenstände, die ausgeliehen und noch nicht zurückgegeben wurden$/ do
  @not_returned.each do |line|
    @contract_element.find(".not_returned_items").should have_content line.model.name
    @contract_element.find(".not_returned_items").should have_content line.item.inventory_code
  end
end
