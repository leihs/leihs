# -*- encoding : utf-8 -*-

Angenommen /^man öffnet eine Werteliste$/ do
  step 'man öffnet einen Vertrag bei der Aushändigung'

  page.driver.browser.close
  new_window = page.driver.browser.window_handles.last
  page.driver.browser.switch_to.window new_window

  find(".modal a", text: _("Value list")).click
  new_window = page.driver.browser.window_handles.last
  page.driver.browser.switch_to.window new_window

  @value_list_element = find(".value_list")
end

Dann /^möchte ich die folgenden Bereiche in der Werteliste sehen:$/ do |table|
  within @value_list_element do
    table.hashes.each do |area|
      case area["Bereich"]
        when "Datum"
          first(".date").should have_content Date.today.year
          first(".date").should have_content Date.today.month
          first(".date").should have_content Date.today.day
        when "Titel"
          first("h1").should have_content @contract.id
        when "Ausleihender"
          first(".customer").should have_content @contract.user.firstname
          first(".customer").should have_content @contract.user.lastname
          first(".customer").should have_content @contract.user.address
          first(".customer").should have_content @contract.user.zip
          first(".customer").should have_content @contract.user.city
        when "Verleiher"
          first(".inventory_pool")
        when "Liste"
          first(".list")
      end
    end
  end
end

Dann /^beinhaltet die Werte\-Liste folgende Spalten:$/ do |table| 
  within @value_list_element.first(".list") do
    table.hashes.each do |area|
      case area["Spaltenname"]
        when "Laufende Nummer"
          @contract.lines.each {|line| first("tr", :text=> line.item.inventory_code).first(".consecutive_number") }
        when "Inventarcode"
          @contract.lines.each {|line| first("tr", :text=> line.item.inventory_code).first(".inventory_code") }
        when "Modellname"
          @contract.lines.each {|line| first("tr", :text=> line.item.inventory_code).first(".model_name").should have_content line.model.name }
        when "End Datum"
          @contract.lines.each {|line|
            first("tr", :text=> line.item.inventory_code).first(".end_date").should have_content line.end_date.year
            first("tr", :text=> line.item.inventory_code).first(".end_date").should have_content line.end_date.month
            first("tr", :text=> line.item.inventory_code).first(".end_date").should have_content line.end_date.day
          }
        when "Anzahl"
          @contract.lines.each {|line| first("tr", :text=> line.item.inventory_code).first(".quantity").should have_content line.quantity }
        when "Wert"
          @contract.lines.each {|line|
            first("tbody tr", :text=> line.item.inventory_code).first(".item_price").text.gsub(/\D/, "").should == ("%.2f" % line.item.price).gsub(/\D/, "")
          }
      end
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
