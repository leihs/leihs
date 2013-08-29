# -*- encoding : utf-8 -*-

Angenommen /^man öffnet eine Werteliste$/ do
  step 'man öffnet einen Vertrag'
  find(".tab", :text=> /(Value List|Werteverzeichnis)/).click
  @value_list_element = find(".value_list")
end

Dann /^möchte ich die folgenden Bereiche in der Werteliste sehen:$/ do |table|
  table.hashes.each do |area|
    case area["Bereich"]
      when "Datum"
        @value_list_element.find(".date").should have_content Date.today.year
        @value_list_element.find(".date").should have_content Date.today.month
        @value_list_element.find(".date").should have_content Date.today.day
      when "Titel"
        @value_list_element.find("h1").should have_content @contract.id
      when "Ausleihender"
        @value_list_element.find(".customer").should have_content @contract.user.firstname
        @value_list_element.find(".customer").should have_content @contract.user.lastname
        @value_list_element.find(".customer").should have_content @contract.user.address
        @value_list_element.find(".customer").should have_content @contract.user.zip
        @value_list_element.find(".customer").should have_content @contract.user.city
      when "Verleiher"
        @value_list_element.find(".inventory_pool")
      when "Liste"
        @value_list_element.find(".list")
      end
  end
end

Dann /^beinhaltet die Werte\-Liste folgende Spalten:$/ do |table| 
  @list = @value_list_element.find(".list")
  table.hashes.each do |area|
    case area["Spaltenname"]
      when "Laufende Nummer"
        @contract.lines.each {|line| @list.find("tr", :text=> line.item.inventory_code).find(".consecutive_number") }
      when "Inventarcode"
        @contract.lines.each {|line| @list.find("tr", :text=> line.item.inventory_code).find(".inventory_code") }
      when "Modellname"
        @contract.lines.each {|line| @list.find("tr", :text=> line.item.inventory_code).find(".model_name").should have_content line.model.name }
      when "Start Datum"
        @contract.lines.each {|line| 
          @list.find("tr", :text=> line.item.inventory_code).find(".start_date").should have_content line.start_date.year 
          @list.find("tr", :text=> line.item.inventory_code).find(".start_date").should have_content line.start_date.month 
          @list.find("tr", :text=> line.item.inventory_code).find(".start_date").should have_content line.start_date.day 
        }
      when "End Datum"
        @contract.lines.each {|line| 
          @list.find("tr", :text=> line.item.inventory_code).find(".end_date").should have_content line.end_date.year 
          @list.find("tr", :text=> line.item.inventory_code).find(".end_date").should have_content line.end_date.month 
          @list.find("tr", :text=> line.item.inventory_code).find(".end_date").should have_content line.end_date.day 
        }
      when "Anzahl"
        @contract.lines.each {|line| @list.find("tr", :text=> line.item.inventory_code).find(".quantity").should have_content line.quantity }
      when "Wert"
        @contract.lines.each {|line|
          @list.find("tbody tr", :text=> line.item.inventory_code).find(".item_price").text.gsub(/\D/, "").should == ("%.2f" % line.item.price).gsub(/\D/, "")
        }
    end
  end
end

Dann /^gibt es eine Zeile für die totalen Werte$/ do
  @list = @value_list_element.find(".list")
  @total = @list.find("tfoot.total")
end

Dann /^diese summierte die Spalten:$/ do |table|
  table.hashes.each do |area|
    case area["Spaltenname"]
      when "Anzahl"
        @total.find(".quantity").should have_content @contract.quantity 
      when "Wert"
        @total.find(".value").text.gsub(/\D/, "").should == ("%.2f" % @contract.lines.map(&:price).sum).gsub(/\D/, "")
    end
  end
end

When(/^die Modelle in der Werteliste sind alphabetisch sortiert$/) do
  names = all(".value_list tbody .model_name").map{|name| name.text}
  names.empty?.should be_false
  expect(names.sort == names).to be_true
end