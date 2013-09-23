# -*- encoding : utf-8 -*-

Angenommen /^man öffnet eine Werteliste$/ do
  step 'man öffnet einen Vertrag bei der Aushändigung'
  find(".tab", :text=> /(Value List|Werteverzeichnis)/, match: :first).click
  @value_list_element = first(".value_list")
end

Dann /^möchte ich die folgenden Bereiche in der Werteliste sehen:$/ do |table|
  table.hashes.each do |area|
    case area["Bereich"]
      when "Datum"
        @value_list_element.first(".date").should have_content Date.today.year
        @value_list_element.first(".date").should have_content Date.today.month
        @value_list_element.first(".date").should have_content Date.today.day
      when "Titel"
        @value_list_element.first("h1").should have_content @contract.id
      when "Ausleihender"
        @value_list_element.first(".customer").should have_content @contract.user.firstname
        @value_list_element.first(".customer").should have_content @contract.user.lastname
        @value_list_element.first(".customer").should have_content @contract.user.address
        @value_list_element.first(".customer").should have_content @contract.user.zip
        @value_list_element.first(".customer").should have_content @contract.user.city
      when "Verleiher"
        @value_list_element.first(".inventory_pool")
      when "Liste"
        @value_list_element.first(".list")
      end
  end
end

Dann /^beinhaltet die Werte\-Liste folgende Spalten:$/ do |table| 
  @list = @value_list_element.first(".list")
  table.hashes.each do |area|
    case area["Spaltenname"]
      when "Laufende Nummer"
        @contract.lines.each {|line| @list.first("tr", :text=> line.item.inventory_code).first(".consecutive_number") }
      when "Inventarcode"
        @contract.lines.each {|line| @list.first("tr", :text=> line.item.inventory_code).first(".inventory_code") }
      when "Modellname"
        @contract.lines.each {|line| @list.first("tr", :text=> line.item.inventory_code).first(".model_name").should have_content line.model.name }
      when "End Datum"
        @contract.lines.each {|line| 
          @list.first("tr", :text=> line.item.inventory_code).first(".end_date").should have_content line.end_date.year
          @list.first("tr", :text=> line.item.inventory_code).first(".end_date").should have_content line.end_date.month
          @list.first("tr", :text=> line.item.inventory_code).first(".end_date").should have_content line.end_date.day
        }
      when "Anzahl"
        @contract.lines.each {|line| @list.first("tr", :text=> line.item.inventory_code).first(".quantity").should have_content line.quantity }
      when "Wert"
        @contract.lines.each {|line|
          @list.first("tbody tr", :text=> line.item.inventory_code).first(".item_price").text.gsub(/\D/, "").should == ("%.2f" % line.item.price).gsub(/\D/, "")
        }
    end
  end
end

Dann /^gibt es eine Zeile für die totalen Werte$/ do
  @list = @value_list_element.first(".list")
  @total = @list.first("tfoot.total")
end

Dann /^diese summierte die Spalten:$/ do |table|
  table.hashes.each do |area|
    case area["Spaltenname"]
      when "Anzahl"
        @total.first(".quantity").should have_content @contract.quantity
      when "Wert"
        @total.first(".value").text.gsub(/\D/, "").should == ("%.2f" % @contract.lines.map(&:price).sum).gsub(/\D/, "")
    end
  end
end

When(/^die Modelle in der Werteliste sind alphabetisch sortiert$/) do
  names = all(".value_list tbody .model_name").map{|name| name.text}
  names.empty?.should be_false
  expect(names.sort == names).to be_true
end
