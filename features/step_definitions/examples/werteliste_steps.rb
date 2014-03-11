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

Angenommen(/^es existiert eine Aushändigung mit mindestens zwei Modellen und einer Option, wo die Bestellmenge mindestens drei pro Modell ist$/) do
  @hand_over = @current_inventory_pool.visits.hand_over.find do |ho|
    ho.contract_lines.instance_eval do
      any? {|cl| cl.is_a? OptionLine } and
        map(&:model).instance_eval do
          uniq.count >= 2 and select{|m| ho.contract_lines.select{|l| l.model == m}.count >= 3 }.uniq.count >= 2
      end
    end
  end
  @hand_over.should_not be_nil
  @lines = @hand_over.lines
end

Wenn(/^es ist pro Modell genau einer Linie ein Gegenstand zugewiesen$/) do
  @models = @lines.select{|l| l.is_a? ItemLine}.map(&:model)

  @models.uniq.each do |m|
    l = @lines.find{|l| l.model == m}
    l.update_attribute(:item, l.model.borrowable_items.by_responsible_or_owner_as_fallback(@current_inventory_pool).sample) unless l.is_a? OptionLine
  end
end

Wenn(/^ich mehrere Linien von der Aushändigung auswähle$/) do
  page.has_selector? "#lines .line input[type='checkbox']"
  @number_of_selected_lines = all("#lines .line input[type='checkbox']").size
  @lines.map(&:id).each {|id| find("#lines .line[data-id='#{id}'] input[type='checkbox']").click }
end

Wenn(/^ich mehrere Linien von der Bestellung auswähle$/) do
  page.has_selector? "#lines .emboss .row input[type='checkbox']"
  @number_of_selected_lines = @order.lines.size
  all("#lines .emboss .row input[type='checkbox']").each {|i| i.click unless i.checked? }
end

Wenn(/^das Werteverzeichniss öffne$/) do
  find("[data-selection-enabled]").find(:xpath, "./following-sibling::*").click
  click_button _("Print Selection")
  page.driver.browser.switch_to.window(page.driver.browser.window_handles.last)
end

Dann(/^sehe ich das Werteverzeichniss für die ausgewählten Linien$/) do
  has_selector? _("Value list")
  find("tfoot.total .quantity").text == @number_of_selected_lines.to_s
end

Dann(/^für die nicht zugewiesenen Linien ist der Preis der höchste Preis eines Gegenstandes eines Models innerhalb des Geräteparks$/) do
  @models.each do |m|
    lines = @lines.select {|l| l.is_a? ItemLine and l.model == m and not l.item.try(:inventory_code)}
    quantity = lines.size
    line = all("tr", text: m.name).find {|line| line.find(".inventory_code").text == "" }
    if line
      line.find(".item_price").text.delete("'").should match /#{(@lines.reload.find{|l| not l.item and l.model == m}.price_or_max_price * quantity).to_s}/
    end
  end
end

Dann(/^für die zugewiesenen Linien ist der Preis der des Gegenstandes$/) do
  lines = @lines.select {|l| l.item.try(:inventory_code)}
  lines.each do |line|
    find("tr", text: line.item.inventory_code).find(".item_price").text.delete("'").should match /#{line.price_or_max_price.to_s}/
  end
end

Dann(/^die nicht zugewiesenen Linien sind zusammengefasst$/) do
  @models.each do |m|
    all("tr", text: m.name).select{|line| line.find(".inventory_code").text == "" }.size.should == 1
  end
end

Dann(/^der Preis einer Option ist der innerhalb des Geräteparks$/) do
  lines = @lines.select {|l| l.is_a? OptionLine }
  lines.each do |l|
    line = find("tr", text: l.model.name)
    line.find(".item_price").text.delete("'").should match /#{@current_inventory_pool.options.find(l.item.id).price * l.quantity}/
  end
end

Angenommen(/^es existiert eine Bestellung mit mindestens zwei Modellen, wo die Bestellmenge mindestens drei pro Modell ist$/) do
  @order = @current_inventory_pool.contracts.submitted.find do |o|
    o.contract_lines.map(&:model).instance_eval do
      uniq.count >= 2 and select{|m| o.contract_lines.select{|l| l.model == m}.count >= 3 }.uniq.count >= 2
    end
  end
  @order.should_not be_nil
  @lines = @order.lines
  @models = @lines.select{|l| l.is_a? ItemLine}.map(&:model)
end

Wenn(/^ich eine Bestellung öffne$/) do
  visit manage_edit_contract_path(@current_inventory_pool, @order)
end
