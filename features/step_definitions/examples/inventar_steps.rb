# encoding: utf-8

Angenommen /^man öffnet die Liste des Inventars$/ do
  begin
    @current_inventory_pool = @current_user.managed_inventory_pools.sample
    visit manage_inventory_path(@current_inventory_pool)
    find("#inventory")
  end while @current_inventory_pool.models.empty?
end

Wenn /^man die Liste des Inventars öffnet$/ do
  step 'man öffnet die Liste des Inventars'
end

Dann /^sieht man Modelle$/ do
  find("#inventory .line[data-type='model']", match: :first)
end

Dann /^man sieht Optionen$/ do
  find("#inventory .line[data-type='option']", match: :first)
end

Dann /^man sieht Pakete$/ do
  package = @current_inventory_pool.items.packages.sample
  step 'ich nach "%s" suche' % package.inventory_code
  find(".line[data-is_package='true']", match: :prefer_exact, text: package.name)
end

########################################################################

def check_existing_inventory_codes(items)
  step "ensure there are no active requests"
  step "sieht man Modelle"
  all(".line[data-type='model']").each do |model_el|
    model_el.find(".button[data-type='inventory-expander'] i.arrow.right").click
    model_el.find(".button[data-type='inventory-expander'] i.arrow.down")
    find(".group-of-lines")
    all(".group-of-lines .line[data-type='item'] .col1of5:nth-child(2)", text: /\w+/).map(&:text).each do |inventory_code|
      items.find_by_inventory_code(inventory_code).should_not be_nil
    end
    model_el.find(".button[data-type='inventory-expander'] i.arrow.down").click
  end
end

Dann /^hat man folgende Auswahlmöglichkeiten die nicht kombinierbar sind$/ do |table|
  items = Item.by_owner_or_responsible(@current_inventory_pool)
  section_tabs = find("#list-tabs")
  section_tabs.all(".active").size.should == 1

  table.hashes.each do |row|
    tab = nil
    case row["auswahlmöglichkeit"]
      when "Aktives Inventar"
        tab = section_tabs.first("a")
        tab.text.should == _("Active Inventory")
        check_existing_inventory_codes(items)
      when "Ausleihbar"
        tab = section_tabs.find("a[data-borrowable='true']")
        tab.click
        check_existing_inventory_codes(items.borrowable)
      when "Nicht ausleihbar"
        tab = section_tabs.find("a[data-unborrowable='true']")
        tab.click
        check_existing_inventory_codes(items.unborrowable)
      when "Ausgemustert"
        tab = section_tabs.find("a[data-retired='true']")
        tab.click
        check_existing_inventory_codes(items.unscoped.where(Item.arel_table[:retired].not_eq(nil)))
      when "Ungenutzte Modelle"
        tab = section_tabs.find("a[data-unused_models='true']")
        tab.click
        step "ensure there are no active requests"
        step "sieht man Modelle"
        all(".line[data-type='model']").each do |model_el|
          model_el.find(".button[data-type='inventory-expander'] span").text.should == "0"
        end
    end
    tab.reload[:class].split.include?("active").should be_true
  end
end

########################################################################

Dann /^hat man folgende Filtermöglichkeiten$/ do |table|
  items = Item.by_owner_or_responsible(@current_inventory_pool)

  section_filter = find("#list-filters")

  table.hashes.each do |row|
    section_filter.all("input[type='checkbox']").select{|x| x.checked?}.map(&:click)
    section_filter.all("input[type='checkbox']").select{|x| x.checked?}.empty?.should be_true
    case row["filtermöglichkeit"]
      when "An Lager"
        section_filter.find("input#in_stock[type='checkbox']").click
        check_existing_inventory_codes(items.in_stock)
      when "Besitzer bin ich"
        section_filter.find("input#owned[type='checkbox']").click
        check_existing_inventory_codes(items.where(:owner_id => @current_inventory_pool))
      when "Defekt"
        section_filter.find("input#broken[type='checkbox']").click
        check_existing_inventory_codes(items.broken)
      when "Unvollständig"
        section_filter.find("input#incomplete[type='checkbox']").click
        check_existing_inventory_codes(items.incomplete)
      when "Verantwortliche Abteilung"
        o = section_filter.find("select#responsibles").all("option[value]").to_a.sample
        o.select_option
        check_existing_inventory_codes(items.where(inventory_pool_id: o[:value]))
        o = section_filter.find("select#responsibles").all("option").first
        o.select_option
    end
  end
end

Dann /^die Filter können kombiniert werden$/ do
  section_filter = find("#list-filters")
  section_filter.all("input[type='checkbox']").select{|x| not x.checked?}.map(&:click)
  section_filter.all("input[type='checkbox']").select{|x| x.checked?}.size.should > 1
end

########################################################################

Dann /^ist die Auswahl "(.*?)" aktiviert$/ do |arg1|
  case arg1
    when "Aktives Inventar"
      find("#list-tabs a.active", text: _("Active Inventory"))
  end
end

Dann /^es sind keine Filtermöglichkeiten aktiviert$/ do
  find("#list-filters").all("input[type='checkbox']").each do |filter|
    filter.checked?.should be_false
  end
end

########################################################################

Wenn /^man eine Modell\-Zeile eines Modells, das weder ein Paket-Modell oder ein Bestandteil eines Paket-Modells ist, sieht$/ do
  page.has_selector? "#inventory .line[data-type='model']"
  all("#inventory .line[data-type='model']").each do |model_line|
    @model = Model.find_by_name(model_line.find(".col2of5 strong").text)
    next if @model.is_package? or @model.items.all? {|i| i.parent}
    @model_line = model_line and break
  end
end

Dann /^enthält die Modell\-Zeile folgende Informationen:$/ do |table|
  table.hashes.each do |row|
    case row["information"]
      when "Bild"
        @model_line.find "img[src*='image_thumb']"
      when "Name des Modells"
        @model_line.find ".col2of5 strong"
      when "Anzahl verfügbar (jetzt)"
        @model_line.find ".col1of5:nth-child(3)", :text => /#{@model.borrowable_items.in_stock.count}.*?\//
      when "Anzahl verfügbar (Total)"
        @model_line.find ".col1of5:nth-child(3)", :text => /\/.*?#{@model.borrowable_items.count}/
    end
  end
end

########################################################################

Wenn /^man eine Gegenstands\-Zeile sieht$/ do
  all(".tab").detect{|x| x["data-tab"] == '{"borrowable":true}'}.click
  find(".filter input#in_stock").click unless find(".filter input#in_stock").checked?
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
  sleep(2.88)
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
  find("select#responsibles option[value='#{@current_inventory_pool.id}']").select_option
  find("#list-filters input#in_stock").click unless find("#list-filters input#in_stock").checked?
  step "ensure there are no active requests"
  find(".button[data-type='inventory-expander'] i.arrow.right", match: :first).click
  @item_line = find(".group-of-lines .line[data-type='item']", match: :first)
  @item = Item.find_by_inventory_code @item_line.find(".col1of5.text-align-left:nth-child(2)").text
end

Wenn /^der Gegenstand nicht an Lager ist und eine andere Abteilung für den Gegenstand verantwortlich ist$/ do
  all("select#responsibles option:not([selected])").detect{|o| o.value != @current_inventory_pool.id.to_s and o.value != ""}.select_option
  find("#list-filters input#in_stock").click if find("#list-filters input#in_stock").checked?
  item = @current_inventory_pool.own_items.detect{|i| not i.inventory_pool_id.nil? and i.inventory_pool != @current_inventory_pool and not i.in_stock?}
  step 'ich nach "%s" suche' % item.inventory_code
  page.has_selector? ".line[data-id='#{item.id}']"
  find(".line[data-id='#{item.model.id}'] .button[data-type='inventory-expander'] i.arrow.right", match: :first).click
  @item_line = find(".group-of-lines .line[data-type='item']", match: :first)
  @item = Item.find_by_inventory_code @item_line.find(".col1of5.text-align-left:nth-child(2)").text
end

Wenn /^meine Abteilung Besitzer des Gegenstands ist die Verantwortung aber auf eine andere Abteilung abgetreten hat$/ do
  all("select#responsibles option:not([selected])").detect{|o| o.value != @current_inventory_pool.id.to_s and o.value != ""}.select_option
  step "ensure there are no active requests"
  find(".button[data-type='inventory-expander'] i.arrow.right", match: :first).click
  @item_line = find(".group-of-lines .line[data-type='item']", match: :first)
  @item = Item.find_by_inventory_code @item_line.find(".col1of5.text-align-left:nth-child(2)").text
end

Dann /^enthält die Options\-Zeile folgende Informationen$/ do |table|
  @option_line = find(".line[data-type='option']", match: :first)
  @option = Option.find_by_inventory_code @option_line.find(".col1of5:nth-child(1)").text
  table.hashes.each do |row|
    case row["information"]
      when "Barcode"
        @option_line.should have_content @option.inventory_code
      when "Name"
        @option_line.should have_content @option.name
      when "Preis"
        (@option.price * 100).to_i.to_s.should == @option_line.find(".col1of5:nth-child(3)").text.gsub(/\D/, "")
      else
        raise 'step not found'
    end
  end
end

Dann /^kann man jedes Modell aufklappen$/ do
  step "man eine Modell-Zeile eines Modells, das weder ein Paket-Modell oder ein Bestandteil eines Paket-Modells ist, sieht"
  within @model_line do
    find(".button[data-type='inventory-expander'] i.arrow.right").click
    find(".button[data-type='inventory-expander'] i.arrow.down")
  end
end

Dann /^man sieht die Gegenstände, die zum Modell gehören$/ do
  @items_element = @model_line.find(:xpath, "following-sibling::div[@class='group-of-lines']")
  @model.items.each do |item|
    @items_element.should have_content item.inventory_code
  end
end

Dann /^so eine Zeile sieht aus wie eine Gegenstands\-Zeile$/ do
  @item_line ||= @items_element.find(".line")
  @item ||= Item.find_by_inventory_code @item_line.find(".col1of5.text-align-left:nth-child(2)").text
  
  if @item.in_stock? && @item.inventory_pool == @current_inventory_pool
    step 'enthält die Gegenstands-Zeile die Gebäudeabkürzung'
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
  @package_line = find(".line[data-is_package='true']")
  within @package_line do
    find(".button[data-type='inventory-expander'] i.arrow.right").click
    find(".button[data-type='inventory-expander'] i.arrow.down")
  end
end

Dann /^man sieht die Pakete dieses Paket\-Modells$/ do
  @packages_element = @package_line.find(:xpath, "following-sibling::span[@class='group-of-lines']")
  package_items = @packages_element.all(".line[data-type='item']")
  @package.items.each do |package|
    @packages_element.should have_content package.inventory_code  
  end
  @item_line = package_items.to_a.sample
  @item = Item.find_by_inventory_code @item_line.find(".col1of5.text-align-left:nth-child(2)").text
end

Dann /^man kann diese Paket\-Zeile aufklappen$/ do
  within @item_line do
    find(".button[data-type='inventory-expander'] i.arrow.right").click
    find(".button[data-type='inventory-expander'] i.arrow.down")
  end
  @package_parts_element = @item_line.find(:xpath, "following-sibling::span[@class='group-of-lines']")
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
  def parsed_query
    href = find("#csv-export")[:href]
    uri = URI.parse href
    uri.path.should == manage_inventory_csv_export_path(@current_inventory_pool)
    Rack::Utils.parse_nested_query uri.query
  end
  parsed_query.keys.size.should == 0
  find("input#in_stock").click
  parsed_query.should == {"in_stock"=>"1"}
end

Dann /^die Datei enthält die gleichen Zeilen, wie gerade angezeigt werden \(inkl\. Filter\)$/ do
  # not testable without an bigger amount of work
end

Wenn /^ich ein[en]* neue[srn]? (.+) hinzufüge$/ do |entity|
  find(".dropdown-holder", text: _("Add inventory")).hover
  click_link entity
end

Und /^ich (?:erfasse|ändere)? ?die folgenden Details ?(?:erfasse|ändere)?$/ do |table|
  # table is a Cucumber::Ast::Table
  find(".button.green", text: _("Save %s") % _("#{get_rails_model_name_from_url.capitalize}"))
  @table_hashes = table.hashes
  @table_hashes.each do |row|
    find(".field .row", match: :prefer_exact, text: row["Feld"]).find(:xpath, ".//input | .//textarea").set row["Wert"]
  end
end

Und /^ich speichere die Informationen/ do
  @model_name_from_url = get_rails_model_name_from_url
  @model_id = (Rails.application.routes.recognize_path current_path)[:id].to_i
  step 'I press "%s"' % (_("Save %s") % _("#{@model_name_from_url.capitalize}"))
end

Dann /^ensure there are no active requests$/ do
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop do
        active = page.evaluate_script('jQuery.active')
        break if active == 0
      end
    end
  end
  wait_for_ajax
end

Dann /^die Informationen sind gespeichert$/ do
  search_string = @table_hashes.detect {|h| h["Feld"] == "Name"}["Wert"]
  step 'ich nach "%s" suche' % search_string
  step 'ensure there are no active requests'
  find(".line", match: :prefer_exact, text: search_string)
  step 'I should see "%s"' % search_string
end

Dann /^die Daten wurden entsprechend aktualisiert$/ do
  search_string = @table_hashes.detect {|h| h["Feld"] == "Name"}["Wert"]
  step 'ich nach "%s" suche' % search_string
  find(".line", :text => search_string).find("a", :text => Regexp.new(_("Edit"),"i")).click

  # check that the same model was modified
  (Rails.application.routes.recognize_path current_path)[:id].to_i.should eq @model_id

  @table_hashes.each do |row|
    field_name = row["Feld"]
    field_value = row["Wert"]

    f = find(".field .row", match: :prefer_exact, text: field_name)
    value_in_field = f.find(:xpath, ".//input | .//textarea").value

    if field_name == "Preis"
      field_value = field_value.to_i
      value_in_field = value_in_field.to_i
    end

    field_value.should eq value_in_field
  end

  click_link("%s" % _("Cancel"))
  find("#inventory-index-view h1", match: :prefer_exact, text: _("List of Inventory"))
  sleep(0.44)
  current_path.should eq @page_to_return
end

Wenn /^ich nach "(.+)" suche$/ do |option_name|
  find("#list-search").set option_name
end

Wenn /^ich eine?n? bestehende[s|n]? (.+) bearbeite$/ do |entity|
  @page_to_return = current_path
  object_name = case entity
                  when "Modell"
                    @model = @current_inventory_pool.models.sample
                    @model.name
                  when "Option"
                    @option = @current_inventory_pool.options.sample
                    @option.name
                end
  step 'ich nach "%s" suche' % object_name
  find(".line", match: :prefer_exact, :text => object_name).find(".button", :text => "#{entity} editieren").click
end

Wenn /^ich ein bestehendes, genutztes Modell bearbeite welches bereits Zubehör hat$/ do
  @model = @current_inventory_pool.models.all.detect {|m| m.accessories.count > 0}
  visit manage_edit_model_path(@current_inventory_pool, @model)
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
    find(".field", text: field_name)
  end
end

Dann /^ich sehe das gesamte Zubehöre für dieses Modell$/ do
  within(".row.emboss", match: :prefer_exact, :text => _("Accessories")) do
    @model.accessories.each do |accessory|
      find(".list-of-lines .line", text: accessory.name)
    end
  end
end

Dann /^ich sehe, welches Zubehör für meinen Pool aktiviert ist$/ do
  within(".row.emboss", match: :prefer_exact, :text => _("Accessories")) do
    @model.accessories.each do |accessory|
      input = find(".list-of-lines .line", text: accessory.name).find("input")
      if @current_inventory_pool.accessories.where(:id => accessory.id).first
        input.checked?.should be_true
      else
        input.checked?.should be_false
      end
    end
  end
end

Wenn /^ich Zubehör hinzufüge und falls notwendig die Anzahl des Zubehör ins Textfeld schreibe$/ do
  within(".row.emboss", match: :prefer_exact, :text => _("Accessories")) do
    @new_accessory_name = "2x #{Faker::Name.name}"
    find("#accessory-name").set @new_accessory_name
    find("#add-accessory").click
  end
end

Dann /^ist das Zubehör dem Modell hinzugefügt worden$/ do
  sleep(0.88)
  find("#inventory-index-view h1", match: :prefer_exact, text: _("List of Inventory"))
  @model.accessories.reload.where(:name => @new_accessory_name).should_not be_nil
end

Dann /^kann ich ein einzelnes Zubehör löschen, wenn es für keinen anderen Pool aktiviert ist$/ do
  accessory_to_delete = @model.accessories.detect{|x| x.inventory_pools.count <= 1}
  find(".row.emboss", match: :prefer_exact, :text => _("Accessories")).find(".list-of-lines .line", text: accessory_to_delete.name).find("button", text: _("Remove")).click
  step 'ich speichere die Informationen'
  step 'ensure there are no active requests'
  find("#inventory-index-view h1", match: :prefer_exact, text: _("List of Inventory"))
  lambda{accessory_to_delete.reload}.should raise_error(ActiveRecord::RecordNotFound)
end

Dann /^kann ich ein einzelnes Zubehör für meinen Pool deaktivieren$/ do
  step 'ensure there are no active requests'
  accessory_to_deactivate = @model.accessories.detect{|x| x.inventory_pools.where(id: @current_inventory_pool.id).first}
  find(".row.emboss", match: :prefer_exact, :text => _("Accessories")).find(".list-of-lines .line", text: accessory_to_deactivate.name).find("input").click
  step 'ich speichere die Informationen'
  sleep(0.88)
  find("#inventory-index-view h1", match: :prefer_exact, text: _("List of Inventory"))
  lambda {@current_inventory_pool.accessories.reload.find(accessory_to_deactivate)}.should raise_error(ActiveRecord::RecordNotFound)
end

Dann /^kann ich mehrere Bilder hinzufügen$/ do
  find("input[type='file']", match: :first, visible: false)
  page.execute_script("$('input:file').attr('class', 'visible');")
  image_field_id = find(".visible", match: :first)
  ["image1.jpg", "image2.jpg", "image3.png"].each do |image|
    image_field_id.set Rails.root.join("features", "data", "images", image)
  end
end

Dann /^ich kann Bilder auch wieder entfernen$/ do
  find(".row.emboss", match: :prefer_exact, :text => _('Images')).find("[data-type='inline-entry']", :text => "image1.jpg").find("button[data-remove]", match: :first).click
  @images_to_save = []
  find(".row.emboss", match: :prefer_exact, :text => _('Images')).all("[data-type='inline-entry']").each do |entry|
    @images_to_save << entry.text.split(" ")[0]
  end
end

Dann /^zu grosse Bilder werden den erlaubten Grössen entsprechend verkleinert$/ do
  step 'ich nach "%s" suche' % @model.name
  find(".line[data-id='#{@model.id}']").find(".button", :text => "Modell editieren").click
  @images_to_save.each do |image_name|
    find("a[href*='#{image_name}'] img[src*='#{image_name.split(".").first}_thumb.#{image_name.split(".").last}']")
  end
end

Dann /^wurden die ausgewählten Bilder für dieses Modell gespeichert$/ do
  @model.images.map(&:filename).sort.should eql @images_to_save.sort
end

Und /^ich speichere das Modell mit Bilder$/ do
  @model_name_from_url = get_rails_model_name_from_url
  step 'I press "%s"' % (_("Save %s") % _("#{@model_name_from_url.capitalize}"))
  find("#inventory-index-view h1", match: :prefer_exact, text: _("List of Inventory"))
end

Angenommen /^ich erstelle ein neues Modell oder ich ändere ein bestehendes Modell$/ do
  @model = Model.all.first
  visit manage_edit_model_path(@current_inventory_pool, @model)
end

Dann /^füge ich eine oder mehrere Datein den Attachments hinzu$/ do
  @attachment_filename = "image1.jpg"
  find("#attachments input[type='file']", visible: false)
  page.execute_script %Q{ $("#attachments input[type='file']").removeClass("invisible"); }
  2.times do
    find("#attachments input[type='file']", visible: true).set Rails.root.join("features","data","images", @attachment_filename)
  end
end

Dann /^kann Attachments auch wieder entfernen$/ do
  find(".row.emboss", match: :prefer_exact, :text => _('Attachments')).find(".list-of-lines button[data-remove]", match: :first).click
end

Dann /^sind die Attachments gespeichert$/ do
  step "ensure there are no active requests"
  find("#inventory-index-view h1", match: :prefer_exact, text: _("List of Inventory"))
  @model.attachments.reload.where(:filename => @attachment_filename).should_not be_empty
end

Dann /^sieht man keine Modelle, denen keine Gegenstänge zugewiesen unter keinem der vorhandenen Reiter$/ do
  all(".inlinetabs .tab").each do |tab|
    tab.click
    page.should_not have_selector(".model.line .toggle .text", :text => "0")
  end
end

Wenn(/^ich eine resultatlose Suche mache$/) do
  begin
    search_term = Faker::Lorem.words.join
  end while not Inventory.filter({search_term: search_term}, @current_inventory_pool).empty?
  find("#list-search").set search_term
end

Dann(/^sehe ich "(.*?)"$/) do |arg1|
  find(".line", text: _("No entries found"))
end
