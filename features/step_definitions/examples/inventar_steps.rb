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
  items = Item.by_owner_or_responsible(@current_inventory_pool)
  section_tabs = find("section .inlinetabs")
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
        wait_until(15) { all(".loading", :visible => true).empty? and not all(".model.line").empty? }
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
        wait_until(15) { all(".loading", :visible => true).empty? and not all(".model.line").empty? }
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
        wait_until(15) { all(".loading", :visible => true).empty? and not all(".model.line").empty? }
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
  items = Item.by_owner_or_responsible(@current_inventory_pool)
  section_filter = find("section .filter")
  (section_filter.all("input[type='checkbox']").select{|x| x.checked?}.empty?).should be_true
  table.hashes.each do |row|
    case row["filtermöglichkeit"]
      when "An Lager"
        cb = section_filter.find("input[type='checkbox'][data-filter='in_stock']")
        cb.click
        wait_until(15) { all(".loading", :visible => true).empty? }
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.in_stock
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Besitzer bin ich"
        cb = section_filter.find("input[type='checkbox'][data-filter='owned']")
        cb.click
        wait_until(15) { all(".loading", :visible => true).empty? }
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.where(:owner_id => @current_inventory_pool)
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Defekt"
        cb = section_filter.find("input[type='checkbox'][data-filter='broken']")
        cb.click
        wait_until(15) { all(".loading", :visible => true).empty? }
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.broken
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Unvollständig"
        cb = section_filter.find("input[type='checkbox'][data-filter='incomplete']")
        cb.click
        wait_until(15) { all(".loading", :visible => true).empty? }
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.incomplete
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Verantwortliche Abteilung"
        s = section_filter.find(".responsible select")
        s.click
        o = s.all("option").last
        o.click
        wait_until(15) { all(".loading", :visible => true).empty? }
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items.where(:inventory_pool_id => o[:"data-responsible_id"])
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
    end
  end
end

Dann /^die Filter können kombiniert werden$/ do
  section_filter = find("section .filter")
  (section_filter.all("input[type='checkbox']").select{|x| x.checked?}.size > 1).should be_true
end

########################################################################

Dann /^ist erstmal die Auswahl "(.*?)" aktiviert$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Dann /^es sind keine Filtermöglichkeiten aktiviert$/ do
  pending # express the regexp above with the code you wish you had
end