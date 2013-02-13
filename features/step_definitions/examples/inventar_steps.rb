# encoding: utf-8

Angenommen /^man öffnet die Liste des Inventars$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_models_path(@current_inventory_pool)
  wait_until(10){ find(".line:not(.navigation)") }
end

Wenn /^man die Liste des Inventars öffnet$/ do
  step 'man öffnet die Liste des Inventars'
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
        s.all("option").last.select_option
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
      @model_line.find ".availability", :text => /#{@model.borrowable_items.in_stock.count}.*?\//
    when "Anzahl verfügbar (Total)"
      @model_line.find ".availability", :text => /\/.*?#{@model.borrowable_items.count}/ 
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
        step 'enthält die Gegenstands-Zeile den Inventarcode'
      when "Ort des Gegenstands"
        step 'enthält die Gegenstands-Zeile den Ort des Gegenstands'
      when "Gebäudeabkürzung"
        step 'enthält die Gegenstands-Zeile die Gebäudeabkürzung'
      when "Raum"
        step 'enthält die Gegenstands-Zeile den Raum'
      when "Gestell"
        step 'enthält die Gegenstands-Zeile das Gestell'
      when "Aktueller Ausleihender"
        step 'enthält die Gegenstands-Zeile den aktuell Ausleihenden'
      when "Enddatum der Ausleihe"
        step 'enthält die Gegenstands-Zeile das Enddatum der Ausleihe'
      when "Verantwortliche Abteilung"
        step 'enthält die Gegenstands-Zeile die Verantwortliche Abteilung'
      else
        raise 'step not found'
    end
  end
end

Dann /^enthält die Gegenstands\-Zeile den Inventarcode$/ do
  @item_line.should have_content @item.inventory_code
end

Dann /^enthält die Gegenstands\-Zeile den Ort des Gegenstands$/ do
  @item_line.should have_content @item.location.to_s
end

Dann /^enthält die Gegenstands\-Zeile die Gebäudeabkürzung$/ do
  @item_line.should have_content @item.location.building.code
end

Dann /^enthält die Gegenstands\-Zeile den Raum$/ do
  @item_line.should have_content @item.location.room
end

Dann /^enthält die Gegenstands\-Zeile das Gestell$/ do
  @item_line.should have_content @item.location.shelf
end

Dann /^enthält die Gegenstands\-Zeile den aktuell Ausleihenden$/ do
  @item_line.should have_content @item.current_borrower.to_s
end

Dann /^enthält die Gegenstands\-Zeile das Enddatum der Ausleihe$/ do
  @item_line.should have_content @item.current_return_date.year
  @item_line.should have_content @item.current_return_date.month
  @item_line.should have_content @item.current_return_date.day
end

Dann /^enthält die Gegenstands\-Zeile die Verantwortliche Abteilung$/ do
  @item_line.should have_content @item.inventory_pool.to_s      
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

Dann /^enthält die Options\-Zeile folgende Informationen$/ do |table|
  @option_line = find(".option.line")
  @option = Option.find_by_inventory_code @option_line.find(".inventory_code").text
  table.hashes.each do |row|
    case row["information"]
      when "Barcode"
        @option_line.should have_content @option.inventory_code
      when "Name"
        @option_line.should have_content @option.name
      when "Preis"
        (@option.price * 100).to_i.to_s.should == @option_line.find(".price").text.gsub(/\D/, "")
      else
        raise 'step not found'
    end
  end
end

Dann /^kann man jedes Modell aufklappen$/ do
  @model_line = find(".model.line")
  @model = Model.find_by_name(@model_line.find(".modelname").text)
  @model_line.find(".toggle .text").click
end

Dann /^man sieht die Gegenstände, die zum Modell gehören$/ do
  @items_element = @model_line.find(:xpath, "following-sibling::div")
  @model.items.each do |item|
    @items_element.should have_content item.inventory_code
  end
end

Dann /^so eine Zeile sieht aus wie eine Gegenstands\-Zeile$/ do
  @item_line ||= @items_element.find(".line")
  @item ||= Item.find_by_inventory_code @item_line.find(".inventory_code").text
  
  if @item.in_stock? && @item.inventory_pool == @current_inventory_pool
    step 'enthält die Gegenstands-Zeile den Ort des Gegenstands'
    step 'enthält die Gegenstands-Zeile den Raum'
    step 'enthält die Gegenstands-Zeile das Gestell'
  elsif not @item.in_stock? && @item.inventory_pool == @current_inventory_pool
    step 'enthält die Gegenstands-Zeile den aktuell Ausleihenden'
    step 'enthält die Gegenstands-Zeile das Enddatum der Ausleihe'
  elsif @item.owner == @current_inventory_pool && @item.inventory_pool != @current_inventory_pool
    step 'enthält die Gegenstands-Zeile die Verantwortliche Abteilung'
    step 'enthält die Gegenstands-Zeile die Gebäudeabkürzung'
    step 'enthält die Gegenstands-Zeile den Raum'
  else
    step 'enthält die Gegenstands-Zeile die Gebäudeabkürzung'
    step 'enthält die Gegenstands-Zeile den Raum'
    step 'enthält die Gegenstands-Zeile das Gestell'
  end
    
end

Dann /^kann man jedes Paket\-Modell aufklappen$/ do
  @package_line = find(".package.model.line")
  @package = Model.find_by_name(@package_line.find(".modelname").text)
  @package_line.find(".toggle .text").click
end

Dann /^man sieht die Pakete dieses Paket\-Modells$/ do
  @packages_element = @package_line.find(:xpath, "following-sibling::div")
  @packages = @packages_element.all(".package.line")
  @package.items.each do |package|
    @packages_element.should have_content package.inventory_code  
  end
  @item_line = @packages.first
  @item = Item.find_by_inventory_code @packages.first.find(".inventory_code").text
end

Dann /^man kann diese Paket\-Zeile aufklappen$/ do
  @item_line.find(".toggle .text").click
  @package_parts_element = @item_line.find(:xpath, "following-sibling::div")
end

Dann /^man sieht die Bestandteile, die zum Paket gehören$/ do
  @item.children.each do |part|
    @package_parts_element.should have_content part.inventory_code
  end
end

Dann /^so eine Zeile zeigt nur noch Inventarcode und Modellname des Bestandteils$/ do
  @item.children.each do |part|
    @package_parts_element.should have_content part.inventory_code
    @package_parts_element.should have_content part.name
  end
end

Dann /^kann man diese Daten als CSV\-Datei exportieren$/ do
  find(".export_csv")
end

Dann /^die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden \(inkl\. Filter\)$/ do
  # not testable without an bigger amount of work
end

Wenn /^ich eine Option bearbeite$/ do
  page.execute_script("$('.content_navigation .arrow').trigger('mouseover');")
  click_link "Option hinzufügen"
end

Und /^ich ändere die folgenden Details$/ do |table|
  # table is a Cucumber::Ast::Table
  @table_hashes = table.hashes
  @table_hashes.each do |row|
    f = find(".key", text: row["Feld"] + ":")
    f.find(:xpath, "./..//input").set row["Wert"]
  end
end

Und /^ich speichere die Option$/ do
  step 'I press "Option speichern"'
end

Dann /^die Option ist gespeichert$/ do
  search_string = @table_hashes.detect {|h| h["Feld"] == "Name"}["Wert"]
  find_field('query').set search_string
  step 'I should see "%s"' % search_string
end
