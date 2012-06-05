# -*- encoding : utf-8 -*-

Angenommen /^man öffnet die Liste des Inventars$/ do
  @current_inventory_pool = @user.managed_inventory_pools.first
  visit backend_inventory_pool_models_path(@current_inventory_pool)
end

Dann /^sieht man Modelle$/ do
  all(".model.line").empty?.should be_false
end

Dann /^man sieht Optionen$/ do
  all(".option.line").empty?.should be_false
end

Dann /^man sieht Pakete$/ do
  all(".model.package.line").empty?.should be_false
end

########################################################################

Dann /^hat man folgende Auswahlmöglichkeiten die nicht kombinierbar sind$/ do |table|
  section_tabs = find("section .inlinetabs")
  items = Item.by_owner_or_responsible(@current_inventory_pool)
  (section_tabs.all(".active").size == 1).should be_true
  table.hashes.each do |row|
    tab = nil
    case row["auswahlmöglichkeit"]
      when "Alles"
        tab = section_tabs.find("a")
        tab[:href].match(/\?/).should be_nil
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Ausgemustert"
        tab = section_tabs.find(:xpath, "a[contains(@href,'borrowable=true')]")
        tab.click
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.unscoped.where(Item.arel_table[:retired].not_eq(nil))
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Ausleihbar"
        tab = section_tabs.find(:xpath, "a[contains(@href,'borrowable=false')]")
        tab.click
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.borrowable
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Nicht ausleihbar"
        tab = section_tabs.find(:xpath, "a[contains(@href,'retired=true')]")
        tab.click
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.unborrowable
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
    end
    tab.reload[:class].split.include?("active").should be_true
  end
end

########################################################################

Dann /^hat man folgende Filtermöglichkeiten$/ do |table|
  section_tabs = find("section .inlinetabs")
  table.hashes.each do |row|
    section_tabs.find("span", :text => row["filtermöglichkeit"])
  end
end

Dann /^die Filter können kombiniert werden$/ do
  pending # express the regexp above with the code you wish you had
end

########################################################################

Dann /^ist erstmal die Auswahl "(.*?)" aktiviert$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Dann /^es sind keine Filtermöglichkeiten aktiviert$/ do
  pending # express the regexp above with the code you wish you had
end