# -*- encoding : utf-8 -*-

Wenn(/^man sich auf der Modellliste befindet$/) do
  @category = Category.first
  visit borrow_models_path(category_id: @category.id)
end

Wenn(/^man sich auf der Modellliste befindet die nicht verfügbare Modelle beinhaltet$/) do
  @start_date ||= Date.today
  @end_date ||= Date.today+1.day
  model = @current_user.models.borrowable.detect do |m|
    quantity = @current_user.inventory_pools.sum do |ip|
      m.availability_in(ip).maximum_available_in_period_summed_for_groups(@start_date, @end_date, @current_user.groups.map(&:id))
    end
    quantity <= 0
  end
  @category = model.categories.first
  visit borrow_models_path(category_id: @category.id)
  page.execute_script %Q{$('#model-list-search input').focus()}
  find("#model-list-search input").set model.name
end

Dann(/^sind alle Geräteparks ausgewählt$/) do
  all("#ip-selector .dropdown-item input").all? &:checked?
end

Dann(/^die Modellliste zeigt Modelle aller Geräteparks an$/) do
  @current_user.models.borrowable.from_category_and_all_its_descendants(@category.id).default_order.paginate(page: 1, per_page: 20).map(&:name)
    .should eq all("#model-list .text-align-left").map(&:text)
end

Dann(/^im Filter steht "(.*?)"$/) do |button_label_de|
  find("#ip-selector .button", text: button_label_de)
end

Angenommen(/^man befindet sich auf der Modellliste$/) do
  step "man sich auf der Modellliste befindet"
end

Wenn(/^man ein bestimmten Gerätepark in der Geräteparkauswahl auswählt$/) do
  page.execute_script %Q($("#ip-selector").trigger("mouseenter"))
  page.should have_selector("#ip-selector .dropdown .dropdown-item", :visible => true)
  @ip ||= @current_user.inventory_pools.first
  find("#ip-selector .dropdown .dropdown-item", text: @ip.name).click
end

Dann(/^sind alle anderen Geräteparks abgewählt$/) do
  page.execute_script %Q($("#ip-selector").trigger("mouseenter"))
  (@current_user.inventory_pools - [@ip]).each do |ip|
    find("#ip-selector .dropdown-item", text: ip.name).first("input").should_not be_checked
  end
end

Dann(/^die Modellliste zeigt nur Modelle dieses Geräteparks an$/) do
  all("#model-list .text-align-left").map(&:text).reject{|t| t.empty?}.should eq @current_user.models.borrowable
                                                  .from_category_and_all_its_descendants(@category.id)
                                                  .by_inventory_pool(@ip.id)
                                                  .default_order.paginate(page: 1, per_page: 20)
                                                  .map(&:name)
end

Dann(/^die Auswahl klappt zu$/) do
  find("#ip-selector .dropdown").should_not be_visible
end

Dann(/^im Filter steht der Name des ausgewählten Geräteparks$/) do
  page.should have_selector("#ip-selector .button", text: @ip.name)
end

Wenn(/^man einige Geräteparks abwählt$/) do
  page.execute_script %Q($("#ip-selector").trigger("mouseenter"))
  @ip = @current_user.inventory_pools.first
  @dropdown_element = find("#ip-selector .dropdown")
  @dropdown_element.first(".dropdown-item", text: @ip.name).first("input").click
end

Dann(/^wird die Modellliste nach den übrig gebliebenen Geräteparks gefiltert$/) do
  page.should have_selector("#model-list .text-align-left")
  all("#model-list .text-align-left").map(&:text).should eq @current_user.models.borrowable
                                                  .from_category_and_all_its_descendants(@category.id)
                                                  .all_from_inventory_pools(@current_user.inventory_pool_ids - [@ip.id])
                                                  .default_order
                                                  .paginate(page: 1, per_page: 20)
                                                  .map(&:name)
end

Dann(/^die Auswahl klappt noch nicht zu$/) do
  find("#ip-selector .dropdown").should be_visible
end

Wenn(/^man alle Geräteparks bis auf einen abwählt$/) do
  page.execute_script %Q($("#ip-selector").trigger("mouseenter"))
  @ip = @current_user.inventory_pools.first
  @ips_for_unselect = @current_user.inventory_pools.where("inventory_pools.id != ?", @ip.id)
  @ips_for_unselect.each do |ip|
    find("#ip-selector .dropdown-item", text: ip.name).first("input").click
  end
end

Dann(/^wird die Modellliste nach dem übrig gebliebenen Gerätepark gefiltert$/) do
  page.should have_selector("#model-list .text-align-left")
  all("#model-list .text-align-left").map(&:text).reject{|t| t.empty?}[0..20].should eq @current_user.models.borrowable
                                                  .from_category_and_all_its_descendants(@category.id)
                                                  .all_from_inventory_pools(@current_user.inventory_pool_ids - @ips_for_unselect.map(&:id))
                                                  .default_order
                                                  .paginate(page: 1, per_page: 20)
                                                  .map(&:name)
end

Dann(/^im Filter steht der Name des übriggebliebenen Geräteparks$/) do
  find("#ip-selector .button", text: @ip.name)
end

Dann(/^kann man nicht alle Geräteparks in der Geräteparkauswahl abwählen$/) do
  page.execute_script %Q($("#ip-selector").trigger("mouseenter"))
  inventory_pool_ids = all("#ip-selector .dropdown-item[data-id]").map{|item| item["data-id"]}
  inventory_pool_ids.each do |ip_id|
    page.should have_selector("#ip-selector .dropdown .dropdown-item", visible: true)
    find("#ip-selector .dropdown-item[data-id='#{ip_id}']").click
  end
  page.should have_selector("#ip-selector .dropdown-item input:checked")
  page.execute_script %Q($("#ip-selector").trigger("mouseleave"))
end

Dann(/^ist die Geräteparkauswahl alphabetisch sortiert$/) do
  all("#ip-selector .dropdown-item[data-id]").map(&:text).should eq @current_user.inventory_pools.order("inventory_pools.name").map(&:name)
end

Dann(/^im Filter steht die Zahl der ausgewählten Geräteparks$/) do
  number_of_selected_ips = (@current_user.inventory_pool_ids - [@ip.id]).length
  find("#ip-selector .button", text: (number_of_selected_ips.to_s + " " + _("Inventory pools")))
end

Wenn(/^man die Liste nach "(.*?)" sortiert$/) do |sort_order|
  page.execute_script %Q($("#model-sorting").trigger("mouseenter"))
  text = case sort_order
    when "Modellname (alphabetisch aufsteigend)"
      "#{_("Model")} (#{_("ascending")})"
    when "Modellname (alphabetisch absteigend)"
      "#{_("Model")} (#{_("descending")})"
    when "Herstellername (alphabetisch aufsteigend)"
      "#{_("Manufacturer")} (#{_("ascending")})"
    when "Herstellername (alphabetisch absteigend)"
      "#{_("Manufacturer")} (#{_("descending")})"
  end
  find("#model-sorting a", :text => text).click
  step "ensure there are no active requests"
  all("#model-list .line").count.should > 0
end

Dann(/^ist die Liste nach "(.*?)" "(.*?)" sortiert$/) do |sort, order|
  attribute = case sort
              when "Modellname"
                "name"
              when "Herstellername"
                "manufacturer"
              end
  direction = case order
              when "(alphabetisch aufsteigend)"
                "asc"
              when "(alphabetisch absteigend)"
                "desc"
              end
  all("#model-list .text-align-left").map(&:text).reject{|t| t.empty?}.should eq @current_user.models.borrowable
                                                  .from_category_and_all_its_descendants(@category.id)
                                                  .order_by_attribute_and_direction(attribute, direction)
                                                  .paginate(page: 1, per_page: 20)
                                                  .map(&:name)
end

Wenn(/^man ein Suchwort eingibt$/) do
  find("#model-list-search input").set " "
  find("#model-list-search input").set "bea panas"
  step "ensure there are no active requests"
end

Dann(/^werden diejenigen Modelle angezeigt, deren Name oder Hersteller dem Suchwort entsprechen$/) do
  find("#model-list .line").text.should match /bea.*panas/i
end

Dann(/^ist kein Ausleihzeitraum ausgewählt$/) do
  find("#start-date").value.should be_nil
  find("#end-date").value.should be_nil
end

Wenn(/^man ein Startdatum auswählt$/) do
  @start_date ||= Date.today
  find("#start-date").set I18n.l @start_date
  find(".ui-state-active").click
end

Dann(/^wird automatisch das Enddatum auf den folgenden Tag gesetzt$/) do
  @end_date ||= Date.today+1.day
  find("#end-date").value.should == I18n.l(@end_date)
end

Dann(/^die Liste wird gefiltert nach Modellen die in diesem Zeitraum verfügbar sind$/) do
  page.should have_selector("#model-list .line")
  all("#model-list .line[data-id]").each do |model_el|
    model = Model.find_by_id(model_el["data-id"])
    model = Model.find_by_id(model_el.reload["data-id"]) if model.nil?
    quantity = @current_user.inventory_pools.sum do |ip|
      model.availability_in(ip).maximum_available_in_period_summed_for_groups(@start_date, @end_date, @current_user.groups.map(&:id))
    end
    if quantity == 0
      @unavailable_model_found = true
      model_el[:class]["grayed-out"].should be
    else
      model_el[:class]["grayed-out"].should_not be
    end
  end
  raise "no unavailable model tested" if @unavailable_model_found.nil?
end

Wenn(/^man ein Enddatum auswählt$/) do
  @end_date = Date.today+1.day
  find("#end-date").set I18n.l @end_date
end

Dann(/^wird automatisch das Startdatum auf den vorhergehenden Tag gesetzt$/) do
  sleep(0.88)
  @start_date = Date.today
  find("#start-date").value.should == I18n.l(@start_date)
end

Angenommen(/^das Startdatum und Enddatum des Ausleihzeitraums sind ausgewählt$/) do
  step 'man ein Startdatum auswählt'
  step 'man ein Enddatum auswählt'
end

Wenn(/^man das Startdatum und Enddatum leert$/) do
  find("#start-date").set ""
  find("#end-date").set ""
  page.execute_script %Q{ $("#start-date, #end-date").trigger("change") }
end

Dann(/^wird die Liste nichtmehr nach Ausleihzeitraum gefiltert$/) do
  page.should_not have_selector(".grayed-out")
end

Wenn(/^kann man für das Startdatum und für das Enddatum den Datepick benutzen$/) do
  find("#start-date").set I18n.l Date.today
  find(".ui-datepicker")
  find("#end-date").set I18n.l Date.today
  find(".ui-datepicker")
end

Dann(/^sieht man die Explorative Suche$/) do
  page.should have_selector("#explorative-search")
  page.should have_selector("#explorative-search a[href*='/models']")
end

Dann(/^man sieht die Modelle der ausgewählten Kategorie$/) do
  category = Category.find Rack::Utils.parse_nested_query(URI.parse(current_url).query)["category_id"]
  all("#model-list .line[data-id]").each do |model_line|
    model = Model.find model_line["data-id"]
    model.categories.include?(category).should be_true
  end
end

Dann(/^man sieht Sortiermöglichkeiten$/) do
  page.should have_selector("#model-sorting")
  page.should have_selector("#model-sorting .dropdown *[data-sort]", visible: false)
end

Dann(/^man sieht die Gerätepark\-Auswahl$/) do
  page.should have_selector("#ip-selector")
  page.should have_selector("#ip-selector .dropdown", visible: false)
end

Dann(/^man sieht die Einschränkungsmöglichkeit eines Ausleihzeitraums$/) do
  page.should have_selector("#start-date")
  page.should have_selector("#end-date")
end

Wenn(/^einen einzelner Modelleintrag beinhaltet$/) do |table|
  model_line = first("#model-list .line")
  model = Model.find model_line["data-id"]
  table.raw.map{|e| e.first}.each do |row|
    case row
      when "Bild"
        model_line.first("img[src*='#{model.id}']")
      when "Modellname"
        model_line.first(".line-col", :text => model.name)
      when "Herstellname"
        model_line.first(".line-col", :text => model.manufacturer)
      when "Auswahl-Schaltfläche"
        model_line.first(".line-col .button")
      else
        raise "Unbekannt"
    end
  end
end

Angenommen(/^man sieht eine Modellliste die gescroll werden muss$/) do
  @category = Category.all.find{|c| c.models.length > 20}
  visit borrow_models_path(category_id: @category.id)
end

Wenn(/^bis ans ende der bereits geladenen Modelle fährt$/) do
  page.execute_script %Q{ $($('.page')[1]).trigger('inview'); }
end

Dann(/^wird der nächste Block an Modellen geladen und angezeigt$/) do
  all("#model-list .line").count.should > 20
end

Wenn(/^man bis zum Ende der Liste fährt$/) do
  has_selector?(".page")
  page.execute_script %Q{ $('.page').trigger('inview'); }
  has_selector?(".page")
end

Dann(/^wurden alle Modelle der ausgewählten Kategorie geladen und angezeigt$/) do
  all("#model-list .line").size.should == @current_user.models.borrowable.from_category_and_all_its_descendants(@category).length
end

Wenn(/^man über das Modell hovered$/) do
  page.execute_script %Q($(".line[data-id='#{@model.id}']").mouseenter())
end

Dann(/^werden zusätzliche Informationen angezeigt zu Modellname, Bilder, Beschreibung, Liste der Eigenschaften$/) do
  find(".tooltipster-default").should have_content @model.name
  page.should have_content @model.description
  @model.properties.take(5).map(&:key).each {|key| page.should have_content key}
  @model.properties.take(5).map(&:value).each {|value| page.should have_content value}
  (0..@model.images.count-1).each do |i|
    page.should have_selector("img[src*='/models/#{@model.id}/image_thumb?offset=#{i}']", :visible => false)
  end
end

Angenommen(/^es gibt ein Modell mit Bilder, Beschreibung und Eigenschaften$/) do
  @model = @current_user.models.borrowable.find {|m| !m.images.blank? and !m.description.blank? and !m.properties.blank?}
end

Angenommen(/^man befindet sich auf der Modellliste mit diesem Modell$/) do
  visit borrow_models_path(category_id: @model.categories.first)
end

Wenn(/^man wählt alle Geräteparks bis auf einen ab$/) do
  step "ensure there are no active requests"
  step 'man ein bestimmten Gerätepark in der Geräteparkauswahl auswählt'
  step "ensure there are no active requests"
end

Wenn(/^man wählt "Alle Geräteparks"$/) do
  step "ensure there are no active requests"
  find("#ip-selector .dropdown-item", :text => _("All inventory pools")).click
  step "ensure there are no active requests"
end

Dann(/^sind alle Geräteparks wieder ausgewählt$/) do
  all("#ip-selector .dropdown-item input[type='checkbox']").each do |checkbox|
    checkbox.checked?.should be_true
  end
end

Dann(/^die Liste zeigt Modelle aller Geräteparks$/) do
  step 'man bis zum Ende der Liste fährt'
  models = @current_user.models.borrowable.from_category_and_all_its_descendants(@category.id)
    .all_from_inventory_pools(all("#ip-selector .dropdown-item[data-id]").map{|ip| ip["data-id"]})
    .order_by_attribute_and_direction "model", "name"
  all("#model-list .text-align-left").map(&:text).reject{|t| t.empty?}.should == models.map(&:name)
end

Angenommen(/^Filter sind ausgewählt$/) do
  find("#model-list-search input").set "a"
  find("input#start-date").set Date.today.strftime("%d.%m.%Y")
  find("input#end-date").set (Date.today + 1).strftime("%d.%m.%Y")
  find("body").click
  page.should_not have_selector(".ui-datepicker-calendar", :visible => true)
  page.execute_script %Q($("#ip-selector").trigger("mouseenter"))
  page.should have_selector("#ip-selector .dropdown-item", :visible => true)
  all("#ip-selector .dropdown-item").last.click
  page.execute_script %Q($("#ip-selector").trigger("mouseleave"))
  page.execute_script %Q($("#model-sorting").trigger("mouseenter"))
  page.should have_selector("#model-sorting a", :visible => true)
  all("#model-sorting a").last.click
  page.execute_script %Q($("#model-sorting").trigger("mouseleave"))
end

Angenommen(/^die Schaltfläche "(.*?)" ist aktivert$/) do |arg1|
  find("#reset-all-filter").visible?
end

Wenn(/^man "Alles zurücksetzen" wählt$/) do
  find("#reset-all-filter").click
  step "ensure there are no active requests"
  all("#model-list .line").count.should > 0
end

Dann(/^sind alle Geräteparks in der Geräteparkauswahl wieder ausgewählt$/) do
  all("#ip-selector input[type='checkbox']").each &:checked?
end

Dann(/^der Ausleihezeitraum ist leer$/) do
  find("input#start-date").value.should be_empty
  find("input#end-date").value.should be_empty
end

Dann(/^die Sortierung ist nach Modellnamen \(aufsteigend\)$/) do
  find(".button", text: _("Model")).first(".icon-circle-arrow-up")
end

Dann(/^die Schaltfläche "(?:.+)" ist deaktiviert$/) do
  page.should have_selector("#reset-all-filter", visible: false)
end

Dann(/^das Suchfeld ist leer$/) do
  find("#model-list-search input").value.should be_empty
end

Dann(/^man sieht wieder die ungefilterte Liste der Modelle$/) do
  all("#model-list .text-align-left").map(&:text).reject{|t| t.empty?}.should eq @current_user.models.from_category_and_all_its_descendants(@category.id).default_order.paginate(page: 1, per_page: 20).map(&:name)
end

Wenn(/^ich alle Filter manuell zurücksetze$/) do
  find("#model-list-search input").set ""
  find("input#start-date").set ""
  find("input#end-date").set ""
  find("body").click
  all(".ui-datepicker-calendar", :visible => true).empty?.should be_true
  page.execute_script %Q($("#ip-selector").trigger("mouseenter"))
  page.should have_selector("#ip-selector .dropdown-item", :visible => true)
  all("#ip-selector .dropdown-item").first.click
  page.execute_script %Q($("#ip-selector").trigger("mouseleave"))
  page.execute_script %Q($("#model-sorting").trigger("mouseenter"))
  page.should have_selector("#model-sorting a", :visible => true)
  all("#model-sorting a").first.click
  page.execute_script %Q($("#model-sorting").trigger("mouseleave"))
end

Dann(/^verschwindet auch die "Alles zurücksetzen" Schaltfläche$/) do
  page.should have_selector("#reset-all-filter", visible: false)
end

Dann(/^die Auswahl klappt nocht nicht zu$/) do
  find("#ip-selector .dropdown").should be_visible
end

Dann(/^wenn ich den Kalendar für dieses Modell benutze$/) do
  find(".line[data-id='#{@model.id}'] *[data-create-order-line]").click
  find("#submit-booking-calendar").click
end

Dann(/^können die zusätzliche Informationen immer noch abgerufen werden$/) do
  step 'man über das Modell hovered'
  step 'werden zusätzliche Informationen angezeigt zu Modellname, Bilder, Beschreibung, Liste der Eigenschaften'
end
