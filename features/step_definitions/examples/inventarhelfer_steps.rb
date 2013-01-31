# encoding: utf-8
Wenn /^man im Inventar Bereich ist$/ do
  find("nav.navigation a", :text => /(Inventar|Inventory)/)
end

Dann /^kann man über die Tabnavigation zum Helferschirm wechseln$/ do
  find("nav#navigation a", :text => /(Helfer|Helper)/).click
  find("h1", :text => /(Inventarhelfer|Inventory Helper)/)
end

Angenommen /^man ist auf dem Helferschirm$/ do
  @current_inventory_pool = @current_user.managed_inventory_pools.first
  visit backend_inventory_pool_inventory_helper_path @current_inventory_pool
end

Dann /^wähle Ich all die Felder über eine List oder per Namen aus$/ do
  find("#fieldname").set Field.last.label
  wait_until {!all(".ui-menu-item a", :visible => true).empty?}
  find(".ui-menu-item a").click

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
  all("#field_selection .field", :visible => true).each do |field|
    field_type = field[:class][/\s\w+\s/].strip
    case field_type

      when "radio"
        field.find("input[type=radio]").click
      when "textarea"
        field.find("textarea").set "This is a text for a textarea"
      when "select"
        field.find("option").select_option
      when "text"
        unless field.all("input[name='item[inventory_code]']").empty?
          field.find("input[type='text']").set "123456"
        else
          field.find("input[type='text']").set "This is a text for a input text"
        end
      when "date"
        field.find(".datepicker").click
        wait_until{ not all(".ui-datepicker-calendar .ui-state-default", :visible => true).empty? }
        find(".ui-datepicker-calendar .ui-state-default").click
      when "autocomplete"
        target_name = field.find('.autocomplete')['data-autocomplete_value_target']
        page.execute_script %Q{ $(".autocomplete[data-autocomplete_value_target='#{target_name}']").focus() }
        page.execute_script %Q{ $(".autocomplete[data-autocomplete_value_target='#{target_name}']").focus() }
        wait_until{ not all(".ui-menu-item",:visible => true).empty? }
        find(".ui-menu-item a").click
      when "checkbox"
        # currently we only have "ausgemustert"
        field.find("input[type='checkbox']").click
        find("[name='item[retired_reason]']").set "This is a text for a input text"
      else
        raise "field type not found"

    end
      
  end
end

Dann /^scanne oder gebe ich den Inventarcode ein$/ do
  @item= @current_inventory_pool.items.first
  find("#item_selection .barcode_target").set @item.inventory_code
  find("#item_selection button[type=submit]").click
end

Dann /^sehe ich alle Werte des Gegenstandes in der Übersicht mit Modellname, die geänderten Werte sind bereits gespeichert$/ do
  FastGettext.locale = @current_user.language.locale_name.gsub(/-/, "_")
  wait_until {!all("#item.selected").empty?}
  Field.all.each do |field|
    value = field.get_value_from_params @item.reload
    within("#item") do
      field_el = all(".field[data-field_id='#{field.id}']").first
      if field_el
        field_type = field_el[:class][/\s\w+\s/].strip
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
            value = field[:values].detect{|v| v["value"] == value}["label"]
            field_el.should have_content _(value)
          end
        else
          field_el.should have_content _(value)
        end
      end
    end
  end
end

Dann /^die geänderten Werte sind hervorgehoben$/ do
  all("#field_selection .field").each do |selected_field|
    find("#item .field[data-field_id='#{selected_field['data-field_id']}']")[:class][/highlight/].should_not be_nil
  end
end

Dann /^wähle Ich die Felder über eine List oder per Namen aus$/ do
  find("#fieldname").click
  wait_until { not all(".ui-menu-item a", :visible => true).empty? }
  find(".ui-menu-item a", :text => /(Notiz|Note)/).click
  find("#fieldname").set Field.last.label
  sleep(1)
  find(".ui-menu-item a").click
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
  step %Q{sehe ich alle Werte des Gegenstandes in der Übersicht, die geänderten Werte sind bereits gespeichert}
  step %Q{die geänderten Werte sind hervorgehoben}
end

Wenn /^man die Editierfunktion nutzt$/ do
  find("#item .content_navigation button", :text => /(editieren|edit)/i).click
end

Dann /^kann man an Ort und Stelle alle Werte des Gegenstandes editieren$/ do
  find("#item input[type='text']")
  all("#item input[type='text']", :visible => true).each do |input|
    input.set "New text for this input"
  end
end

Dann /^man die Änderungen speichert$/ do
  find("#item .content_navigation button", :text => /(Speichern|Save)/i).click
end

Dann /^sind sie gespeichert$/ do
  wait_until{!all("#item .field", :visible => true).empty?}
  Field.where(:type => "text").each do |field|
    value = field.get_value_from_params @item.reload
    if not field[:visibility_dependency_field_id] and value.is_a? String
      value.should == "New text for this input"
    end
  end
end

Wenn /^man seine Änderungen widerruft$/ do
  find("#item .content_navigation button", :text => /(abbrechen|cancel)/i).click
end

Dann /^sind die Änderungen widerrufen$/ do
  @item.to_json.should == @item.reload.to_json
end

Dann /^man sieht alle ursprünglichen Werte des Gegenstandes in der Übersicht$/ do
  step %Q{sehe ich alle Werte des Gegenstandes in der Übersicht, die geänderten Werte sind bereits gespeichert}
end