# -*- encoding : utf-8 -*-

Angenommen /^man öffnet die Liste des Inventars$/ do
  @current_inventory_pool = @user.managed_inventory_pools.first
  visit backend_inventory_pool_models_path(@current_inventory_pool)
  wait_until(10){ find(".line:not(.navigation)") }
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
        tab[:"data-tab"].should == "null"
        all(".model.line").each do |model_el|
          model_el.find(".toggle .text").click if model_el.all(".toggle.open").empty?
          model_el.all(".item.line").each do |item_el|
            items
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Ausgemustert"
        tab = section_tabs.find(:xpath, "a[contains(@data-tab,'{\"borrowable\":true}')]")
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
        tab = section_tabs.find(:xpath, "a[contains(@data-tab,'{\"borrowable\":false}')]")
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
        tab = section_tabs.find(:xpath, "a[contains(@data-tab,'{\"retired\":true}')]")
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

Dann /^ist die Auswahl "(.*?)" aktiviert$/ do |arg1|
  case arg1
    when "Alles"
      find("section .inlinetabs").find(".tab.active").text.should == find("section .inlinetabs").find(:xpath, "a[contains(@data-tab,'null')]").text
  end
end

Dann /^es sind keine Filtermöglichkeiten aktiviert$/ do
  all(".filter input").each do |filter|
    filter.checked?.should be_false
  end
end

########################################################################

Wenn /^man eine Modell\-Zeile sieht$/ do
  @model_line = find(".model.line")
  @model = Model.find_by_name(@model_line.find(".modelname").text)
end

Dann /^enthält die Modell\-Zeile folgende Informationen:$/ do |table|
  table.hashes.each do |row|
    case row["information"]
    when "Bild"
      @model_line.find ".image"
    when "Name des Modells"
      @model_line.find ".modelname"
    when "Anzahl verfügbar (jetzt)"
      av = @model_line.find ".availability"
      av.text.should have_content "#{@model.borrowable_items.in_stock.count} /"
    when "Anzahl verfügbar (Total)"
      av = @model_line.find ".availability"
      av.text.should have_content "/ #{@model.borrowable_items.count}"
    end
  end
end

########################################################################

Wenn /^man eine Gegenstands\-Zeile sieht$/ do
  all(".tab").detect{|x| x["data-tab"] == '{"borrowable":true}'}.click
  wait_until { all(".loading", :visible => true).empty? }
  find(".filter input[data-filter='in_stock']").click unless find(".filter input[data-filter='in_stock']").checked?
end

Dann /^enthält die Gegenstands\-Zeile folgende Informationen:$/ do |table|
  table.hashes.each do |row|
    case row["information"]
      when "Inventarcode"
        @item_line.should have_content @item.inventory_code
      when "Ort des Gegenstands"
        @item_line.should have_content @item.location.to_s
      when "Gebäudeabkürzung"
        @item_line.should have_content @item.location.building.code
      when "Raum"
        @item_line.should have_content @item.location.room
      when "Gestell"
        @item_line.should have_content @item.location.shelf
      when "Aktueller Ausleihender"
        @item_line.should have_content @item.current_borrower.to_s
      when "Enddatum der Ausleihe"
        @item_line.should have_content @item.current_return_date.year
        @item_line.should have_content @item.current_return_date.month
        @item_line.should have_content @item.current_return_date.day
      when "Verantwortliche Abteilung"
        @item_line.should have_content @item.inventory_pool.to_s        
      else
        raise 'step not found'
    end
  end
end

Wenn /^der Gegenstand an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist$/ do
  find(".responsible option[data-responsible_id='#{@current_inventory_pool.id}']").select_option
  find(".filter input[data-filter='in_stock']").click unless find(".filter input[data-filter='in_stock']").checked?
  wait_until { all(".loading", :visible => true).empty? }
  all(".toggle .text").each {|toggle| toggle.click}
  @item_line = find(".items .item.line")
  @item = Item.find_by_inventory_code @item_line.find(".inventory_code").text
end

Wenn /^der Gegenstand nicht an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist$/ do
  find(".responsible option[data-responsible_id='#{@current_inventory_pool.id}']").select_option
  find(".filter input[data-filter='in_stock']").click if find(".filter input[data-filter='in_stock']").checked?
  wait_until { all(".loading", :visible => true).empty? }
  all(".toggle .text").each {|toggle| toggle.click}
  @item_line = find(".items .item.line .item_location.borrower").find(:xpath, "..")
  @item = Item.find_by_inventory_code @item_line.find(".inventory_code").text
end

Wenn /^meine Abteilung Besitzer des Gegenstands ist die Verantwortung aber auf eine andere Abteilung abgetreten hat$/ do
  find(".responsible option[data-responsible_id!='#{@current_inventory_pool.id}']").select_option
  wait_until { all(".loading", :visible => true).empty? }
  all(".toggle .text").each {|toggle| toggle.click}
  @item_line = find(".items .item.line")
  @item = Item.find_by_inventory_code @item_line.find(".inventory_code").text
end