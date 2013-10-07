# encoding: utf-8

def fill_in_autocomplete_field field_name, field_value
  step "ensure there are no active requests"
  within find("form .field", match: :prefer_exact, text: field_name) do
    find("input", match: :first).click
    find("input", match: :first).set field_value
    step "ensure there are no active requests"
    page.has_selector?("a", text: field_value, visible: true)
    find("a", match: :prefer_exact, text: field_value, visible: true).click
  end
end

def check_fields_and_their_values table
  table.hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]

    within first(".field", text: field_name) do
      case field_type
      when "autocomplete"
        first("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        first("input[checked][type='radio']").value.should == field_value
      when "radio"
        first("label", text: field_value).first("input").checked?.should be_true
      else
        first("input,textarea").value.should == field_value
      end
    end
  end
end

Angenommen /^man befindet sich auf der Liste des Inventars$/ do
  visit backend_inventory_pool_inventory_path(@current_inventory_pool)
end

Dann /^kann man einen Gegenstand erstellen$/ do
  page.execute_script("$('.content_navigation .arrow').trigger('mouseover');")
  click_link _("Create %s") % _("Item")
  current_path.should eql new_backend_inventory_pool_item_path(@current_inventory_pool)
end

Angenommen /^man navigiert zur Gegenstandserstellungsseite$/ do
  visit new_backend_inventory_pool_item_path(@current_inventory_pool)
end

Wenn /^ich die folgenden Informationen erfasse$/ do |table|
  @table_hashes = table.hashes

  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]
    matched_field = all("form").last.find(".field", match: :prefer_exact, text: field_name)
    case field_type
      when "radio must"
        matched_field.first("input[value='#{field_value}']").set true
      when "checkbox"
        matched_field.first("input").set (field_value == "checked")
      when "select"
        matched_field.select field_value
      when "autocomplete"
        find("form .field", match: :prefer_exact, text: field_name)
        matched_field.first("input").click
        matched_field.first("input").set field_value
        step "ensure there are no active requests"
        find(".ui-autocomplete a", match: :prefer_exact, text: field_value, visible: true).click
      else
        matched_field.first("input,textarea").set ""
        matched_field.first("input,textarea").set field_value
    end
  end
end

Wenn /^ich erstellen druecke$/ do
  first("button", text: _("Save %s") % _("Item")).click
  step "ensure there are no active requests"
end

Dann /^ist der Gegenstand mit all den angegebenen Informationen erstellt$/ do
  first("a[data-tab*='retired']").click if (@table_hashes.detect {|r| r["Feldname"] == "Ausmusterung"}["Wert"]) == "Ja"
  find_field('query').set (@table_hashes.detect {|r| r["Feldname"] == "Inventarcode"}["Wert"])
  all("li.modelname").first.text.should =~ /#{@table_hashes.detect {|r| r["Feldname"] == "Modell"}["Wert"]}/
  first(".toggle .icon").click
  first(".button", text: 'Gegenstand editieren').click

  #all("form").count.should == 2
  step 'hat der Gegenstand alle zuvor eingetragenen Werte'
end

Dann /^hat der Gegenstand alle zuvor eingetragenen Werte$/ do
  @table_hashes.each do |hash_row|
    field_name = hash_row["Feldname"]
    field_value = hash_row["Wert"]
    field_type = hash_row["Type"]
    matched_field = all("form").last.find(".field", match: :first, text: field_name)
    case field_type
      when "autocomplete"
        matched_field.first("input,textarea").value.should == (field_value != "Keine/r" ? field_value : "")
      when "select"
        matched_field.all("option").detect(&:selected?).text.should == field_value
      when "radio must"
        matched_field.first("input[checked][type='radio']").value.should == field_value
      when ""
        matched_field.first("input,textarea").value.should == field_value
    end
  end
end

Dann /^man wird zur Liste des Inventars zurueckgefuehrt$/ do
  current_path.should eql backend_inventory_pool_inventory_path(@current_inventory_pool)
end

Wenn /^jedes Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
    when "Inventarcode"
      @inventory_code_value = "test"
      @inventory_code_field = first(".field", text: must_field_name).first("input,textarea")
      @inventory_code_field.set @inventory_code_value
    when "Modell"
      model_name = Model.first.name
      fill_in_autocomplete_field must_field_name, model_name
    when "Projektnummer"
      first(".field", text: "Bezug").first("input[value='investment']").set true
      @project_number_value = "test"
      @project_number_field = first(".field", text: must_field_name).first("input,textarea")
      @project_number_field.set @project_number_value
    when "Anschaffungskategorie"
      first(".field", text: "Anschaffungskategorie").first("select option:not([value=''])").select_option
    else
      raise 'unknown field'
    end
  end
end

Wenn /^kein Pflichtfeld ist gesetzt$/ do |table|
  table.raw.flatten.each do |must_field_name|
    case must_field_name
      when "Inventarcode"
        first(".field", text: must_field_name).first("input,textarea").set ""
      when "Modell"
        first(".field", text: must_field_name).first("input").set ""
      when "Projektnummer"
        first(".field", text: "Bezug").first("input[value='investment']").set true
        first(".field", text: must_field_name).first("input,textarea").set ""
      when "Anschaffungskategorie"
        first(".field", text: "Anschaffungskategorie").first("select option[value='']").select_option
      else
        raise 'unknown field'
    end
  end
end

Wenn /^ich das gekennzeichnete "(.+)" leer lasse$/ do |must_field_name|
  @must_field_name = must_field_name
  if not first(".field", text: @must_field_name).all("input,textarea").empty?
    field_id = first(".field", text: @must_field_name)["data-field_id"]
    first(".field", text: @must_field_name).first("input,textarea").set ""
    page.execute_script %Q{ $(".field[data-field_id=#{field_id}] input.autocomplete").trigger("change") }
  elsif not first(".field", text: @must_field_name).all("select").empty?
    first(".field", text: @must_field_name).first("select option[value='']").select_option
  else
    raise "unkown field"
  end
end

Dann /^kann das Modell nicht erstellt werden$/ do
  step "ich erstellen druecke"
  step "ensure there are no active requests"
  Item.find_by_inventory_code("").should be_nil
  Item.find_by_inventory_code("test").should be_nil
end

Dann /^die anderen Angaben wurde nicht gelöscht$/ do
  if @must_field_name == "Modell"
    @inventory_code_field.value.should eql @inventory_code_value
    @project_number_field.value.should eql @project_number_value
  end
end

Dann /^ist der Barcode bereits gesetzt$/ do
  first(".field", text: "Inventarcode").first("input").value.should_not be_empty
end

Dann /^Letzte Inventur ist das heutige Datum$/ do
  first(".field", text: "Letzte Inventur").first("input").value.should eq Date.today.strftime("%d.%m.%Y")
end

Dann /^folgende Felder haben folgende Standardwerte$/ do |table|
  check_fields_and_their_values table
end

Angenommen(/^man setzt Bezug auf Investition$/) do
  first("input[name='item[properties][reference]'][value='investment']").click
end

Dann(/^sind die folgenden Werte im Feld Anschaffungskategorie hinterlegt$/) do |table|
  @table_hashes = table.hashes
  @table_hashes.each do |hash|
    first("select[name='item[properties][anschaffungskategorie]'] option[value='#{hash.values.first}']").select_option
  end
end

Angenommen(/^ich befinde mich auf der Erstellungsseite eines Gegenstandes$/) do
  visit new_backend_inventory_pool_item_path(@current_inventory_pool)
end

Wenn(/^ich einen nicht existierenen Lieferanten angebe$/) do
  @new_supplier = Faker::Lorem.words(rand 1..3).join(' ')
  Supplier.find_by_name(@new_supplier).should be_nil
  find(".field", text: _("Supplier")).find("input").set @new_supplier
end

Dann(/^wird der neue Lieferant erstellt$/) do
  page.should have_content _("List of Inventory")
  Supplier.find_by_name(@new_supplier).should_not be_nil
end

Dann(/^bei dem erstellten Gegestand ist der neue Lieferant eingetragen$/) do
  Item.find_by_inventory_code("test").supplier.name.should == @new_supplier
end
