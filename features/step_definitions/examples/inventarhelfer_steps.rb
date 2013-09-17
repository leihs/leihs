# encoding: utf-8
Wenn /^man im Inventar Bereich ist$/ do
  find("nav.navigation a", :text => _("Inventory")).click
  current_path.should == backend_inventory_pool_inventory_path(@current_inventory_pool)
end

Dann /^kann man über die Tabnavigation zum Helferschirm wechseln$/ do
  find("nav#navigation a", :text => _("Helper")).click
  find("h1", :text => /(Inventarhelfer|Inventory Helper)/)
end

Angenommen /^man ist auf dem Helferschirm$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_inventory_helper_path @current_inventory_pool
end

Dann /^wähle Ich all die Felder über eine List oder per Namen aus$/ do
  find("#fieldname").click
  wait_until {!all(".ui-menu-item a", :visible => true).empty?}
  number_of_items_left = all(".ui-menu-item a", :visible => true).size

  number_of_items_left.times do 
    find("#fieldname").click
    wait_until {!all(".ui-menu-item a", :visible => true).empty?}
    find(".ui-menu-item a").click
  end  
end

Dann /^ich setze all ihre Initalisierungswerte$/ do
  @data = {}
  Field.all.each do |field|
    next if all(".field[data-field_id='#{field[:id]}']").empty?
    case field[:type]
      when "radio"
        find(".field[data-field_id='#{field[:id]}'] input[type=radio]").click
        @data[field[:id]] = find(".field[data-field_id='#{field[:id]}'] input[type=radio]").value
      when "textarea"
        find(".field[data-field_id='#{field[:id]}'] textarea").set "This is a text for a textarea"
        @data[field[:id]] = find(".field[data-field_id='#{field[:id]}'] textarea").value
      when "select"
        find(".field[data-field_id='#{field[:id]}'] option").select_option
        @data[field[:id]] = find(".field[data-field_id='#{field[:id]}'] option").value
      when "text"
        unless all(".field[data-field_id='#{field[:id]}'] input[name='item[inventory_code]']").empty?
          find(".field[data-field_id='#{field[:id]}'] input[type='text']").set "123456"
        else
          find(".field[data-field_id='#{field[:id]}'] input[type='text']").set "This is a text for a input text"
        end
        @data[field[:id]] = find(".field[data-field_id='#{field[:id]}'] input[type='text']").value
      when "date"
        find(".field[data-field_id='#{field[:id]}'] .datepicker").click
        wait_until{ not all(:xpath, "//*[contains(@class, 'ui-state-default')]").empty? }
        find(:xpath, "//*[contains(@class, 'ui-state-default')]").click
        @data[field[:id]] = find(".field[data-field_id='#{field[:id]}'] input.datepicker").value
      when "autocomplete"
        target_name = find(".field[data-field_id='#{field[:id]}'] .autocomplete")['data-autocomplete_value_target']
        page.execute_script %Q{ $(".autocomplete[data-autocomplete_value_target='#{target_name}']").focus() }
        page.execute_script %Q{ $(".autocomplete[data-autocomplete_value_target='#{target_name}']").focus() }
        wait_until{ not all(".ui-menu-item a",:visible => true).empty? }
        find(".ui-menu-item a").click
        @data[field[:id]] = find(".field[data-field_id='#{field[:id]}'] .autocomplete")
      when "autocomplete-search"
        find(".field[data-field_id='#{field[:id]}'] input").set "Sharp Beamer"
        find(".field[data-field_id='#{field[:id]}'] input").click
        wait_until {not all("a", text: "Sharp Beamer").empty?}
        find(".field[data-field_id='#{field[:id]}'] a", text: "Sharp Beamer").click
        @data[field[:id]] = Model.find_by_name("Sharp Beamer").id
      when "checkbox"
        # currently we only have "ausgemustert"
        find(".field[data-field_id='#{field[:id]}'] input[type='checkbox']").click
        find("[name='item[retired_reason]']").set "This is a text for a input text"
        @data[field[:id]] = "This is a text for a input text"
      else
        raise "field type not found"
    end
  end
end

Dann /^ich setze das Feld "(.*?)" auf "(.*?)"$/ do |field_name, value|
  field = Field.find find(".field", text: field_name)["data-field_id"]
  case field[:type]
  when "radio"
    find(".field[data-field_id='#{field[:id]}'] label", :text => value).click
  when "select"
    find(".field[data-field_id='#{field[:id]}'] option", :text => value).select_option
  when "checkbox"
    find(".field[data-field_id='#{field[:id]}'] label", :text => value).click
  else
    raise "unknown field"
  end
end

Dann /^scanne oder gebe ich den Inventarcode von einem Gegenstand ein, der am Lager und in keinem Vertrag vorhanden ist$/ do
  @item = @current_inventory_pool.items.find {|i| i.in_stock? and i.contract_lines.blank?}
  find("#item_selection .barcode_target").set @item.inventory_code
  find("#item_selection button[type=submit]").click
end

Dann /^sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert$/ do
  FastGettext.locale = @current_user.language.locale_name.gsub(/-/, "_")
  wait_until {!all("#item.selected").empty?}
  Field.all.each do |field|
    next if all(".field[data-field_id='#{field[:id]}']").empty?
    value = field.get_value_from_params @item.reload
    within("#item") do
      field_el = all(".field[data-field_id='#{field.id}']").first
      if field_el
        field_type = field_el[:class][/\s(\w(-\w)?)+\s/].strip
        if field_type == "date"
          unless value.blank?
            value = Date.parse(value) if value.is_a?(String)
            field_el.should have_content value.year
            field_el.should have_content value.month
            field_el.should have_content value.day
          end
        elsif field[:attribute] == "retired"
          unless value.blank?
            field_el.should have_content _(field[:values].first[:label])
          end
        elsif field_type == "radio"
          if value
            value = field[:values].detect{|v| v[:value] == value}[:label]
            field_el.should have_content _(value)
          end
        elsif field_type == "select"
          if value
            value = field[:values].detect{|v| v[:value] == value}[:label]
            field_el.should have_content _(value)
          end
        elsif field_type == "autocomplete"
          if value
            value = field.as_json["values"].detect{|v| v["value"] == value}["label"]
            field_el.should have_content _(value)
          end
        elsif field_type == "autocomplete-search"
          if value
            if field[:label] == "Model"
              value = Model.find(value).name
              field_el.should have_content value
            end
          end
        else
          field_el.should have_content _(value)
        end
      end
    end
  end

  find(".field[data-field_id='#{Field.find_by_label("Model").id}']").should have_content @item.reload.model.name
end

Dann /^die geänderten Werte sind hervorgehoben$/ do
  all("#field_selection .field").each do |selected_field|
    find("#item .field[data-field_id='#{selected_field['data-field_id']}']")[:class][/highlight/].should_not be_nil
  end
end

Dann /^wähle Ich die Felder über eine List oder per Namen aus$/ do
  field = Field.all.select{|f| f[:readonly] == nil and f[:type] != "autocomplete-search"}.last
  find("#fieldname").click
  find("#fieldname").set field.label
  find("#fieldname").native.send_keys([:down, :return])
  @all_editable_fields = all("#field_selection .field", :visible => true)
end

Dann /^ich setze ihre Initalisierungswerte$/ do
  all("#field_selection .field input", :visible => true).each do |input|
    input.set "Test123"
  end
end

Dann /^scanne oder gebe ich den Inventarcode eines Gegenstandes ein der nicht gefunden wird$/ do
  find("#item_selection .barcode_target").set "THIS FOR SURE NO INVENTORY CODE"
  find("#item_selection button[type=submit]").click
end

Dann /^erhählt man eine Fehlermeldung$/ do
  find(".notification.error", :text => /(Gegenstand .*? nicht gefunden|item .*? was not found)/)
end

Dann /^gebe ich den Anfang des Inventarcodes eines Gegenstand ein$/ do
  @item= @current_inventory_pool.items.first
  find("#item_selection .barcode_target").set @item.inventory_code[0..1]
end

Dann /^wähle den Gegenstand über die mir vorgeschlagenen Suchtreffer$/ do
  wait_until{!all(".ui-menu-item").empty?}
  find(".ui-menu-item a", :text => @item.inventory_code).click
end

Angenommen /^man editiert ein Gerät über den Helferschirm mittels Inventarcode$/ do
  step %Q{man ist auf dem Helferschirm}
  step %Q{wähle Ich die Felder über eine List oder per Namen aus}
  step %Q{ich setze ihre Initalisierungswerte}
  step %Q{scanne oder gebe ich den Inventarcode ein}
  step %Q{sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert}
  step %Q{die geänderten Werte sind hervorgehoben}
end

Wenn /^man die Editierfunktion nutzt$/ do
  find("#item .content_navigation button", :text => /(editieren|edit)/i).click
end

Dann /^kann man an Ort und Stelle alle Werte des Gegenstandes editieren$/ do
  within("#item") do
    step %Q{ich setze all ihre Initalisierungswerte}
  end
end

Dann /^man die Änderungen speichert$/ do
  find("#item .content_navigation button", :text => /(Speichern|Save)/i).click
end

Dann /^sind sie gespeichert$/ do
  step %Q{sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert}
end

Wenn /^man seine Änderungen widerruft$/ do
  find("#item .content_navigation button", :text => /(abbrechen|cancel)/i).click
end

Dann /^sind die Änderungen widerrufen$/ do
  @item.to_json.should == @item.reload.to_json
end

Dann /^man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht$/ do
  step %Q{sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert}
end

Dann(/^wähle ich das Feld "(.*?)" aus der Liste aus$/) do |field|
  find("#fieldname").click
  find("#fieldname").set field
  wait_until {all(".ui-menu-item a")[0].text == field}
  find("#fieldname").native.send_keys([:down, :return])
  @all_editable_fields = all("#field_selection .field", :visible => true)
end

Dann(/^ich setze den Wert für das Feld "(.*?)"$/) do |field|
  find(".field", text: field).find("input").set "Test123"
end

Angenommen(/^es existiert ein Gegenstand, welches sich denselben Ort mit einem anderen Gegenstand teilt$/) do
  location = Location.find {|l| l.items.count >= 2}
  @item, @item_2 = location.items.first, location.items.second
  @item_2_location = @item_2.location
end

Dann(/^gebe ich den Anfang des Inventarcodes des spezifischen Gegenstandes ein$/) do
  find("#item_selection .barcode_target").set @item.inventory_code[0..1]
end

Dann(/^der Ort des anderen Gegenstandes ist dergleiche geblieben$/) do
  @item_2.reload.location.should == @item_2_location
end

Wenn(/^"(.*?)" ausgewählt und auf "(.*?)" gesetzt wird, dann muss auch "(.*?)" angegeben werden$/) do |field, value, dependent_field|
  find("#fieldname").click
  find("#fieldname").set field
  sleep(0.5)
  find("#fieldname").native.send_keys([:down, :return])
  step %Q{ich setze das Feld "#{field}" auf "#{value}"}
  find(".field", text: dependent_field)
end

Wenn(/^ein Pflichtfeld nicht ausgefüllt\/ausgewählt ist, dann lässt sich der Inventarhelfer nicht nutzen$/) do
  step %Q{scanne oder gebe ich den Inventarcode ein}
end

Angenommen(/^man editiert das Feld "(.*?)" eines ausgeliehenen Gegenstandes$/) do |name|
  field = Field.all.detect{|f| _(f.label) == name}
  step %Q{wähle ich das Feld "#{name}" aus der Liste aus}
  @item = @current_inventory_pool.items.not_in_stock.sample
  @item_before = @item.to_json
  step %Q{scanne oder gebe ich den Inventarcode ein}
end

Dann(/^erhalt man eine Fehlermeldung, dass man diese Eigenschaft nicht editieren kann, da dass Gerät ausgeliehen ist$/) do
  page.should have_content _("The responsible inventory pool cannot be changed because the item is currently not in stock.")
  @item_before.should == @item.reload.to_json
end
