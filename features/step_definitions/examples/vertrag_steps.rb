# -*- encoding : utf-8 -*-

Angenommen /^man öffnet einen Vertrag$/ do
  steps %Q{
     When I open a hand over
      And I select an item line and assign an inventory code
      And I click hand over
     Then I see a summary of the things I selected for hand over
     When I click hand over inside the dialog
     Then the contract is signed for the selected items
  }
end

Dann /^möchte ich die folgenden Bereiche sehen:$/ do |table|
  contract = find("#print section.contract")
  @contract = @customer.contracts.signed.sort_by(&:updated_at).last
  table.hashes.each do |area|
    case area["Bereich"]
       when "Datum"
         contract.find(".date").should have_content Date.today.year
         contract.find(".date").should have_content Date.today.month
         contract.find(".date").should have_content Date.today.day
       when "Titel"
         contract.find("h1").should have_content @contract.id
       when "Ausleihender"
         contract.find(".customer")
       when "Verleier"
       when "Liste 1"
       when "Liste 2"
       when "Liste der Zwecke"
       when "Zusätzliche Notiz"
       when "Hinweis auf AGB"
       when "Unterschrift des Ausleihenden"
       when "Seitennummer"
       when "Barcode"
       when "Vertragsnummer"
     end
   end
end