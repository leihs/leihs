# encoding: utf-8

Angenommen /^man öffnet die Liste des Inventars$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_inventory_path(@current_inventory_pool)
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
  step 'ich nach "%s" suche' % @current_inventory_pool.items.packages.last.inventory_code
  wait_until { all(".loading", :visible => true).empty? }
  wait_until {not all(".model.package.line").empty?}
  step 'ich nach "%s" suche' % " "
  wait_until { all(".loading", :visible => true).empty? }
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
        step "ensure there are no active requests"
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
        step "ensure there are no active requests"
        page.execute_script %Q{ $(".model.line .toggle:not(.open) .text").click() }
        all(".model.line").each do |model_el|
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
        step "ensure there are no active requests"
        page.execute_script %Q{ $(".model.line .toggle:not(.open) .text").click() }
        all(".model.line").each_with_index do |model_el, i|
          all(".model.line")[i].all(".item.line").each_with_index do |item_el, j|
            items.in_stock
            .find_by_inventory_code(all(".model.line")[i].all(".item.line")[j].find(".inventory_code").text).should_not be_nil
          end
        end
      when "Besitzer bin ich"
        cb = section_filter.find("input[type='checkbox'][data-filter='owned']")
        cb.click
        step "ensure there are no active requests"
        page.execute_script %Q{ $(".model.line .toggle:not(.open) .text").click() }
        all(".model.line").each_with_index do |model_el, i|
          all(".model.line")[i].all(".item.line").each do |item_el|
            items.where(:owner_id => @current_inventory_pool)
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Defekt"
        cb = section_filter.find("input[type='checkbox'][data-filter='broken']")
        cb.click
        step "ensure there are no active requests"
        page.execute_script %Q{ $(".model.line .toggle:not(.open) .text").click() }
        all(".model.line").each do |model_el|
          model_el.all(".item.line").each do |item_el|
            items.broken
            .find_by_inventory_code(item_el.find(".inventory_code").text).should_not be_nil
          end
        end
      when "Unvollständig"
        cb = section_filter.find("input[type='checkbox'][data-filter='incomplete']")
        cb.click
        step "ensure there are no active requests"
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
        step "ensure there are no active requests"
        page.execute_script %Q{ $(".model.line .toggle:not(.open) .text").click() }
        unless all(".model.line").empty?
          all(".model.line").each_with_index do |model_el, i|
            all(".model.line")[i].all(".item.line").each_with_index do |item_el, j|
              items.where(:inventory_pool_id => o[:"data-responsible_id"])
              .find_by_inventory_code(all(".model.line")[i].all(".item.line")[j].find(".inventory_code").text).should_not be_nil
            end
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
  step 'ich nach "%s" suche' % " "
end

Wenn /^der Gegenstand an Lager ist und meine Abteilung für den Gegenstand verantwortlich ist$/ do
  find(".responsible option[data-responsible_id='#{@current_inventory_pool.id}']").select_option
  find(".filter input[data-filter='in_stock']").click unless find(".filter input[data-filter='in_stock']").checked?
  step "ensure there are no active requests"
  page.execute_script %Q{ $(".toggle:not(.open) .text").click() }
  @item_line = find(".items .item.line")
  @item = Item.find_by_inventory_code @item_line.find(".inventory_code").text
end

Wenn /^der Gegenstand nicht an Lager ist und meine oder andere Abteilung für den Gegenstand verantwortlich ist$/ do
  find(".responsible option[data-responsible_id='#{@current_inventory_pool.id}']").select_option
  find(".filter input[data-filter='in_stock']").click if find(".filter input[data-filter='in_stock']").checked?
  step 'ich nach "%s" suche' % @current_inventory_pool.items.detect{|i| not i.inventory_pool_id.nil? and not i.in_stock?}.inventory_code
  wait_until { all(".loading", :visible => true).empty? }
  wait_until {not all(".items .item.line .item_location.borrower").empty?}
  all(".toggle .text").each {|toggle| toggle.click}
  @item_line = find(".items .item.line .item_location.borrower").find(:xpath, "..")
  @item = Item.find_by_inventory_code @item_line.find(".inventory_code").text
end

Wenn /^meine Abteilung Besitzer des Gegenstands ist die Verantwortung aber auf eine andere Abteilung abgetreten hat$/ do
  find(".responsible option[data-responsible_id!='#{@current_inventory_pool.id}']").select_option
  wait_until { all(".loading", :visible => true).empty? }
  all(".toggle .text").each {|toggle| toggle.click}
  index = 0
  while not @item or not @item.in_stock?
    @item_line = all(".items .item.line")[index]
    @item = Item.find_by_inventory_code @item_line.find(".inventory_code").text
    index = index+1
    raise("no item found") if index > 20
  end
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
  @package = @current_inventory_pool.items.packages.last.model
  step 'ich nach "%s" suche' % @package.name
  @package_line = find(".package.model.line")
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

Wenn /^ich eine? neue[sr]? (.+) hinzufüge$/ do |entity|
  page.execute_script("$('.content_navigation .arrow').trigger('mouseover');") if entity == "Option"
  click_link "#{entity} erstellen"
end

Und /^ich (?:erfasse|ändere)? ?die folgenden Details ?(?:erfasse|ändere)?$/ do |table|
  # table is a Cucumber::Ast::Table
  @table_hashes = table.hashes
  @table_hashes.each do |row|
    f = find(".key", text: row["Feld"] + ":")
    f.find(:xpath, "./..//input | ./..//textarea") .set row["Wert"]
  end
end

Und /^ich speichere die Informationen/ do
  @model_name_from_url = get_rails_model_name_from_url
  @model_id = (Rails.application.routes.recognize_path current_path)[:id].to_i
  step 'I press "%s"' % (_("Save %s") % _("#{@model_name_from_url.capitalize}"))
end

Dann /^ensure there are no active requests$/ do
  wait_until {page.evaluate_script(%Q{jQuery.active}) == 0}
end

Dann /^die Informationen sind gespeichert$/ do
  search_string = @table_hashes.detect {|h| h["Feld"] == "Name"}["Wert"]
  step 'ich nach "%s" suche' % search_string
  wait_until { all(".loading", :visible => true).empty? }
  step 'I should see "%s"' % search_string
end

Dann /^die Daten wurden entsprechend aktualisiert$/ do
  search_string = @table_hashes.detect {|h| h["Feld"] == "Name"}["Wert"]
  step 'ich nach "%s" suche' % search_string
  wait_until { all(".loading", :visible => true).empty? }
  find(".line", :text => search_string).find("a", :text => Regexp.new(_("Edit"),"i")).click

  # check that the same model was modified
  (Rails.application.routes.recognize_path current_path)[:id].to_i.should eq @model_id

  @table_hashes.each do |row|
    field_name = row["Feld"]
    field_value = row["Wert"]

    f = find(".key", text: field_name + ":")
    value_in_field = f.find(:xpath, "./..//input | ./..//textarea").value

    if field_name == "Preis"
      field_value = field_value.to_i
      value_in_field = value_in_field.to_i
    end

    field_value.should eq value_in_field
  end

  click_link("%s" % _("Cancel"))
  current_path.should eq @page_to_return
end

Wenn /^ich nach "(.+)" suche$/ do |option_name|
  find_field('query').set option_name
end

Wenn /^ich eine?n? bestehende[s|n]? (.+) bearbeite$/ do |entity|
  @page_to_return = current_path
  object_name = case entity
                when "Modell"
                  @model = Model.all.first
                  @model.name
                when "Option"
                  @option = Option.all.first
                  @option.name
                end
  step 'ich nach "%s" suche' % object_name
  wait_until { find(".line", :text => object_name).find(".button", :text => "#{entity} editieren") }.click
end

Wenn /^ich ein bestehendes Modell bearbeite welches bereits Zubehör hat$/ do
  @model = Model.all.detect {|m| m.accessories.count > 0}
  visit edit_backend_inventory_pool_model_path(@current_inventory_pool, @model)
end

Dann /^(?:die|das|der) neue[sr]? (?:.+) ist erstellt$/ do
  step "die Informationen sind gespeichert"
end

Wenn /^ich einen Namen eines existierenden Modelles eingebe$/ do
  existing_model_name = Model.all.first.name
  step %{ich ändere die folgenden Details}, table(%{
    | Feld    | Wert                   |
    | Name    | #{existing_model_name} | })
end

Dann /^wird das Modell nicht gespeichert, da es keinen (?:eindeutigen\s)?Namen hat$/ do
  step 'I should see "%s"' % (_("Save %s") % _("#{@model_name_from_url.capitalize}"))
end

Dann /^habe ich die Möglichkeit, folgende Informationen zu erfassen:$/ do |table|
  table.raw.flatten.all? do |field_name|
    page.has_xpath? "//div[@class='field' and (descendant::input | descendant::textarea) and .//*[contains(text(), '#{field_name}')]]"
  end.should be_true
end

Dann /^ich sehe das gesamte Zubehöre für dieses Modell$/ do
  within(".field", :text => _("Accessories")) do
    @model.accessories.each do |accessory|
      find(".field-inline-entry", :text => accessory.name)
    end
  end
end

Dann /^ich sehe, welches Zubehör für meinen Pool aktiviert ist$/ do
  within(".field", :text => _("Accessories")) do
    @model.accessories.each do |accessory|
      input = find(".field-inline-entry", :text => accessory.name).find("input")
      if @current_inventory_pool.accessories.where(:id => accessory.id).first
        input.checked?.should be_true
      else
        input.checked?.should be_false
      end
    end
  end
end

Wenn /^ich Zubehör hinzufüge und falls notwendig die Anzahl des Zubehör ins Textfeld schreibe$/ do
  within(".field", :text => _("Accessories")) do
    @new_accessory_name = "2x #{Faker::Name.name}"
    find(".add-input").set @new_accessory_name
    find(".add-button").click
  end
end

Dann /^ist das Zubehör dem Modell hinzugefügt worden$/ do
  @model.accessories.reload.where(:name => @new_accessory_name).should_not be_nil
end

Dann /^kann ich ein einzelnes Zubehör löschen, wenn es für keinen anderen Pool aktiviert ist$/ do
  accessory_to_delete = @model.accessories.detect{|x| x.inventory_pools.count <= 1}
  find(".field", :text => _("Accessories")).find(".field-inline-entry", :text => accessory_to_delete.name).find("label", :text => _("Delete")).click
  step 'ich speichere die Informationen'
  wait_until{all(".loading", :visible => true).size == 0}
  lambda{accessory_to_delete.reload}.should raise_error(ActiveRecord::RecordNotFound)
end

Dann /^kann ich ein einzelnes Zubehör für meinen Pool deaktivieren$/ do
  accessory_to_deactivate = @model.accessories.detect{|x| x.inventory_pools.where(id: @current_inventory_pool.id).first}
  find(".field", :text => _("Accessories")).find(".field-inline-entry", :text => accessory_to_deactivate.name).find("input").click
  step 'ich speichere die Informationen'
  wait_until{all(".loading", :visible => true).size == 0}
  lambda {@current_inventory_pool.accessories.reload.find(accessory_to_deactivate)}.should raise_error(ActiveRecord::RecordNotFound)
end

Dann /^kann ich mehrere Bilder hinzufügen$/ do
  wait_until{find("input[type='file']")}
  page.execute_script("$('input:file').attr('class', 'visible');")
  image_field_id = find ".visible"
  ["image1.jpg", "image2.jpg", "image3.png"].each do |image|
    image_field_id.set Rails.root.join("features", "data", "images", image)
  end
end

Dann /^ich kann Bilder auch wieder entfernen$/ do
  find(".field", :text => _('Images')).find(".field-inline-entry .clickable").click
  @images_to_save = ["image2.jpg", "image3.png"]
end

Dann /^zu grosse Bilder werden den erlaubten Grössen entsprechend verkleinert$/ do
  step 'ich nach "%s" suche' % @model.name
  wait_until { find(".line", :text => @model.name).find(".button", :text => "Modell editieren") }.click
  @images_to_save.each do |image_name|
    find("a[href*='#{image_name}']").find("img[src*='#{image_name.split(".").first}_thumb.#{image_name.split(".").last}']")
  end
end

Dann /^wurden die ausgewählten Bilder für dieses Modell gespeichert$/ do
  @model.images.map(&:filename).sort.should eql @images_to_save.sort
end

Und /^ich speichere das Modell mit Bilder$/ do
  @model_name_from_url = get_rails_model_name_from_url
  step 'I press "%s"' % (_("Save %s") % _("#{@model_name_from_url.capitalize}"))
  page.has_content? _("List of Models")
end

Angenommen /^ich erstelle ein neues Modell oder ich ändere ein bestehendes Modell$/ do
  @model = Model.all.first
  visit edit_backend_inventory_pool_model_path @current_inventory_pool, @model
end

Dann /^füge ich eine oder mehrere Datein den Attachments hinzu$/ do
  @attachment_filename = "image1.jpg"
  2.times do
    find("#attachments_filepicker").set Rails.root.join("features","data","images", @attachment_filename)
  end
end

Dann /^kann Attachments auch wieder entfernen$/ do
  find(".field", :text => _('Attachments')).find(".field-inline-entry .clickable").click
end

Dann /^sind die Attachments gespeichert$/ do
  wait_until {all(".loading", :visible => true).empty?}
  @model.attachments.where(:filename => @attachment_filename).empty?.should be_false
end

Dann /^sieht man keine Modelle, denen keine Gegenstänge zugewiesen unter keinem der vorhandenen Reiter$/ do
  all(".inlinetabs .tab").each do |tab|
    tab.click
    wait_until {page.evaluate_script(%Q{jQuery.active}) == 0}
    all(".model.line .toggle .text", :text => "0").size.should == 0
  end
end
